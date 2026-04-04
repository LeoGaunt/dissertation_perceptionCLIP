oxfordpets_simple_template = [
    lambda c: f'a photo of a {c}, a type of pet.',
]

oxfordpets_main_template = [
    lambda c: f'a photo of a {c}, a type of pet',
]

oxfordpets_factor_templates = {
    "species": {
        "others": [""],
        "dog": ["dog"],
        "cat": ["cat"],
    },
    "background": {
        "others": [""],
        "indoors": ["indoors"],
        "outdoors": ["outdoors"],
        "bed": ["on a bed"],
        "couch": ["on a couch"],
        "beach": ["at the beach"],
        "park": ["in a park"],
        "grass": ["on grass"],
        "tree": ["on a tree"],
    },
    "pose": {
        "others": [""],
        "sitting": ["sitting"],
        "running": ["running"],
        "sleeping": ["sleeping"],
        "eating": ["eating"],
        "playing": ["playing"],
    },
    "interaction": {
        "others": [""],
        "pet_interaction": ["interacting with another pet"],
        "human_interaction": ["interacting with a person"],
        "toy": ["playing with a toy"],
        "held": ["being held"],
        "petted": ["being petted"],
    },
}

oxfordpets_bad_factor_templates = {
    "species": {
        "lizard": ["lizard"],
        "hamster": ["hamster"],
        "rabbit": ["rabbit"],
    },
    "background": {
        "car": ["in a car"],
        "kitchen": ["in a kitchen"],
        "office": ["in an office"],
        "in space": ["in space"],
    },
    "pose": {
        "flying": ["flying"],
        "swimming": ["swimming"],
        "climbing": ["climbing"],
    },
    "interaction": {
        "front-flipping": ["front-flipping"],
        "back-flipping": ["back-flipping"],
        "dancing": ["dancing"],
    },
}

oxfordpets_bad_factor_templates_with_others = {
    "species": {
        "others": [""],
        "lizard": ["lizard"],
        "hamster": ["hamster"],
        "rabbit": ["rabbit"],
    },
    "background": {
        "others": [""],
        "car": ["in a car"],
        "kitchen": ["in a kitchen"],
        "office": ["in an office"],
        "in space": ["in space"],
    },
    "pose": {
        "others": [""],
        "flying": ["flying"],
        "swimming": ["swimming"],
        "climbing": ["climbing"],
    },
    "interaction": {
        "others": [""],
        "front-flipping": ["front-flipping"],
        "back-flipping": ["back-flipping"],
        "dancing": ["dancing"],
    },
}
