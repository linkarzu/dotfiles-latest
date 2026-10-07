"""Pick which OBS scene a hotkey changes: the live program or the Studio Mode preview.

With Studio Mode on, a scene hotkey only loads the scene into the preview so
the live output stays put (for example on Starting Soon) until a transition.
"""


def preview_mode(client) -> bool:
    """True only when OBS confirms Studio Mode is enabled."""
    try:
        response = client.get_studio_mode_enabled()
    except Exception as error:
        raise RuntimeError(
            f"OBS Studio Mode state could not be read ({type(error).__name__})."
        ) from None
    return getattr(response, "studio_mode_enabled", None) is True


def target_name(preview: bool) -> str:
    return "preview-scene" if preview else "program-scene"


def current_scene(client, preview: bool) -> str:
    if preview:
        return client.get_current_preview_scene().current_preview_scene_name
    return client.get_current_program_scene().current_program_scene_name


def request_scene(client, scene_name: str, preview: bool) -> None:
    if preview:
        client.set_current_preview_scene(scene_name)
    else:
        client.set_current_program_scene(scene_name)
