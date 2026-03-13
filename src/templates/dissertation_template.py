dissertation_simple_template = [
    lambda c: f'a photo of {c}.',
]

dissertation_main_template = [
    lambda c: f'a photo of {c}',
]


dissertation_factor_templates = {
    "location": {
        "in_water": ["in water"],
        "in_air": ["in the air"],
        "on_fire": ["on fire"],
    },
    "planet": {
        "sun": ["on the sun"],
        "moon": ["on the moon"],
        "mars": ["on mars"],
    },
    "direction": {
        "inverted": ["inverted"],
        "inside_out": ["inside out"],
    },
}

