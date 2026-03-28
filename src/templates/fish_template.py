fish_simple_template = [
    lambda c: f'a photo of {c}, a type of fish.',
]

fish_main_template = [
    lambda c: f'a photo of {c}, a type of fish',
]


fish_factor_templates = {
    "in": {
        "in_water": ["in water"],
        "on_land": ["on land"],
        "no_background": ["with no background"],
        "held_by_human": ["held by a human"],
        "others": [""],
    },
    "size": {
        "small": ["a small"],
        "medium": ["a medium-sized"],
        "large": ["a large"],
        "others": [""],
    },
    "amount": {
        "single": ["a single"],
        "multiple": ["multiple"],
        "others": [""],
    },
    "location": {
        "ocean": ["in the ocean"],
        "river": ["in a river"],
        "lake": ["in a lake"],
        "pond": ["in a pond"],
        "fish_tank": ["in a fish tank"],
        "others": [""],
    },
    "liveness": {
        "alive": ["alive"],
        "dead": ["dead"],
        "cooked": ["cooked"],
        "others": [""],
    }
}

