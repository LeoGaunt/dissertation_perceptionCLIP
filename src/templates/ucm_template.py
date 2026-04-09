ucm_simple_template = [
    lambda c: f'a satellite photo of {c}.',
]

ucm_main_template = [
    lambda c: f'a satellite photo of {c}',
]


ucm_factor_templates_eurosat = {
    "condition": {
        "normal": [""],
        "cool": ["cool"],
        "nice": ["nice"],
        "weird": ["weird"],
    },
    "source": {
        "others": [""],
        "nasa": ["by NASA"],
        "google_earth": ["by Google Earth"],
    },
}

ucm_factor_templates = {
    "condition": {
        "normal": [""],
        "clear": ["clear"],
        "overcast": ["overcast"],
        "hazy": ["hazy"],
    },
    "source": {
        "others": [""],
        "nasa": ["by NASA"],
        "google_earth": ["by Google Earth"],
    },
    "land_use": {
        "urban": ["urban"],
        "rural": ["rural"],
        "suburban": ["suburban"],
        "coastal": ["coastal"],
        "mixed": ["mixed"],
        "others": [""],
    }
        
}