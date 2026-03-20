import os
import torch
import torchvision
from torch.utils.data import Dataset, DataLoader


class Lila:
    def __init__(self,
                 preprocess,
                 location=os.path.expanduser('~/data/lila'),
                 batch_size=128,
                 num_workers=16,
                 classnames=None,
                 custom=False,
                 seed=0,
                 **kwargs):
        self.train_dataset = None
        self.val_dataset = None
        self.test_dataset = torchvision.datasets.ImageFolder(root=location, transform=preprocess)

        self.train_loader = None
        self.val_loader = None
        self.test_loader = DataLoader(self.test_dataset, batch_size=batch_size, shuffle=False,
                                      num_workers=num_workers)

        self.classnames = [
            "acorn_woodpecker", "american_badger", "american_crow", "american_robin",
            "barn_owl", "bat", "black_bear", "black-tailed_jackrabbit", "bobcat",
            "brush_rabbit", "burrowing_owl", "california_quail", "california_thrasher",
            "california_towhee", "canada_goose", "cattle", "common_raven",
            "cottontail_rabbit", "coyote", "dark-eyed_junco", "domestic_cat",
            "domestic_dog", "domestic_horse", "duck_species", "eastern_grey_squirrel",
            "elk_or_deer", "gray_fox", "great_horned_owl", "heron_or_egret",
            "invertebrate", "merriam's_chipmunk", "mourning_dove", "mouse_or_rat",
            "mule_deer", "northern_band-tailed_pigeon", "northern_flicker", "puma",
            "rabbit", "raccoon", "red_fox", "red-shouldered_hawk", "red-tailed_hawk",
            "reptile", "river_otter", "spotted_skunk", "spotted_towhee", "steller's_jay",
            "striped_skunk", "tule_elk", "turkey", "turkey_vulture", "unknown_bird",
            "unknown_hawk", "unknown_nightjar", "unknown_owl", "unknown_squirrel",
            "virginia_opossum", "western_blue_bird", "western_grey_squirrel",
            "western_screech_owl", "western_scrub-jay", "wild_boar",
        ]

