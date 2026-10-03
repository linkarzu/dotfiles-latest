#!/usr/bin/env python3
"""Generate a WAV clip with Gemini TTS.

The Gemini API key is read from the macOS Keychain, the same entry the OBS
meeting manager member TTS uses. It only ever travels in the request header,
never in a URL, a process argument, or any output.

Usage:
  gemini-tts.py --out sounds/virgin-mode/activated.wav \
    --voice Kore --style "calm futuristic AI assistant" "Virgin mode activated"
"""

import argparse
import base64
import json
import subprocess
import sys
import wave
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen

KEYCHAIN_SERVICE = "obs-meeting-manager.member-tts"
KEYCHAIN_ACCOUNT = "gemini-api"
GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/interactions"
MODEL = "gemini-3.8-flash-tts"
# Each model has its own daily request limit
RATE_LIMIT_FALLBACK_MODEL = "gemini-3.8-flash-lite-tts"
SAMPLE_RATE = 24_000


def load_api_key() -> str:
    result = subprocess.run(
        ["/usr/bin/security", "find-generic-password", "-w",
         "-s", KEYCHAIN_SERVICE, "-a", KEYCHAIN_ACCOUNT],
        capture_output=True, text=True, timeout=5, check=False,
    )
    key = result.stdout.strip() if result.returncode == 0 else ""
    if not key:
        sys.exit(f"Gemini key not found in Keychain ({KEYCHAIN_SERVICE} / {KEYCHAIN_ACCOUNT})")
    return key


def request_audio(model: str, text: str, voice: str, style: str, api_key: str) -> dict:
    # The style travels as speech metadata so the model reads the text
    # verbatim instead of speaking the style
    content: dict = {"type": "text", "text": text}
    if style:
        content["annotations"] = [{"type": "speech_metadata", "style": style}]
    payload = {
        "model": model,
        "input": [{"type": "user_input", "content": [content]}],
        "response_format": {"type": "audio"},
        "generation_config": {"speech_config": [{"voice": voice}]},
    }
    request = Request(
        GEMINI_URL,
        data=json.dumps(payload).encode(),
        method="POST",
        headers={"Content-Type": "application/json", "X-Goog-Api-Key": api_key},
    )
    with urlopen(request, timeout=60) as response:
        return json.load(response)


def extract_audio(result: dict) -> tuple[bytes, str]:
    for step in result.get("steps", []):
        for part in step.get("content") or []:
            if part.get("type") == "audio" and part.get("data"):
                return base64.b64decode(part["data"]), part.get("mime_type", "")
    sys.exit("Gemini response had no audio")


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("text")
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--voice", default="Kore")
    parser.add_argument("--style", default="")
    args = parser.parse_args()

    api_key = load_api_key()
    try:
        try:
            result = request_audio(MODEL, args.text, args.voice, args.style, api_key)
        except HTTPError as error:
            if error.code != 429:
                raise
            result = request_audio(
                RATE_LIMIT_FALLBACK_MODEL, args.text, args.voice, args.style, api_key
            )
    except HTTPError as error:
        # Only the status and Gemini's message, never the request headers
        try:
            message = json.load(error).get("error", {}).get("message", "")
        except (json.JSONDecodeError, AttributeError):
            message = ""
        sys.exit(f"Gemini TTS failed: HTTP {error.code} {message}")
    except URLError as error:
        sys.exit(f"Gemini TTS failed: {error.reason}")
    finally:
        api_key = ""

    audio, mime_type = extract_audio(result)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    if "wav" in mime_type.lower():
        args.out.write_bytes(audio)
    else:
        # Raw 16-bit mono PCM
        with wave.open(str(args.out), "wb") as clip:
            clip.setnchannels(1)
            clip.setsampwidth(2)
            clip.setframerate(SAMPLE_RATE)
            clip.writeframes(audio)
    print(args.out)


if __name__ == "__main__":
    main()
