marine_simple_template = [
    lambda c: f'a photo of {c}, a marine animal',
]

marine_main_template = [
    lambda c: f'a photo of {c}, a marine animal',
]

marine_factor_templates = {
    "in": {
        "in_water": ["in water"],
        "on_land": ["on land"],
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
        "floor": ["on the sea floor"],
        "coral_reef": ["in a coral reef"],
        "seaweed": ["in seaweed"],
        "rock": ["on a rock"],
        "others": [""],
    },
    "state": {
        "swimming": ["swimming"],
        "stationary": ["stationary"],
        "others": [""],
    }
    
}