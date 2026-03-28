lila_simple_template = [
    lambda c: f'a photo of {c}, a type of wildlife.',
]

lila_main_template = [
    lambda c: f'a photo of {c}, a type of wildlife',
]

lila_factor_templates = {
    "in": {
        "forest": ["in a forest"],
        "grassland": ["in grassland"],
        "urban": ["in an urban area"],
        "scrubland": ["in scrubland"],
        "wetland": ["in a wetland"],
        "others": [""],
    },
    "time": {
        "day": ["during the day"],
        "night": ["at night"],
        "dusk_or_dawn": ["at dusk or dawn"],
        "others": [""],
    },
    "amount": {
        "single": ["a single"],
        "multiple": ["multiple"],
        "others": [""],
    },
    "activity": {
        "moving": ["moving"],
        "stationary": ["stationary"],
        "foraging": ["foraging"],
        "others": [""],
    },
    "camera_view": {
        "front": ["viewed from the front"],
        "side": ["viewed from the side"],
        "rear": ["viewed from the rear"],
        "others": [""],
    },
    "image_quality": {
        "clear": ["in a clear image"],
        "motion_blur": ["with motion blur"],
        "infrared": ["in an infrared image"],
        "others": [""],
    }
}