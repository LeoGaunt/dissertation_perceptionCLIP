dissertation_simple_template = [
    lambda c: f'a photo of {c}.',
]

dissertation_main_template = [
    lambda c: f'a photo of {c}',
]


dissertation_factor_templates = {
    "on": {
        "on_road": ["on the road"],
        "in_train_station": ["in a train station"],
        "in_bus_station": ["in a bus station"],
    },
    "direction": {
        "front": ["from the front"],
        "back": ["from the back"],
        "side": ["from the side"],
    },
    "amount": {
        "single": ["a single"],
        "multiple": ["multiple"],
    },
    "weather": {
        "sunny": ["in sunny weather"],
        "rainy": ["in rainy weather"],
        "snowy": ["in snowy weather"],
    },
    "decker": {
        "single_decker": ["a single-decker"],
        "double_decker": ["a double-decker"],
    }
}

