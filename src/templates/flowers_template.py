flowers_simple_template = [
    lambda c: f'a photo of a {c}, a type of flower.',
]

flowers_main_template = [
    lambda c: f'a photo of a {c}, a type of flower'
]


flowers_factor_templates = {
    "background": {
        "others": [""],
        "forest": ["in the forest"],
        "garden": ["in the garden"],
        "water": ["on water"],
        "dark_background": ["with dark background"],
    },
    "illumination": {
        "normal": [""],
        "bright": ["sunny", "bright"],
        "dark": ["dark", "dim"],
    },
    "petals": {
        "normal": [""],
        "bloomed": ["fully bloomed"],
        "budding": ["budding"],
        "wilting": ["wilting"],
    },
    "quality": {
        "others": [""],
        "high-res": ["high resolution"],
        "low-res": ["low resolution"],
    },
}