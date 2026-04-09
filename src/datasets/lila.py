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
            "acorn woodpecker",
            "american crow",
            "american robin",
            "barn owl",
            "black-tailed jackrabbit",
            "bobcat",
            "brush rabbit",
            "california quail",
            "california thrasher",
            "california towhee",
            "cattle",
            "common raven",
            "cottontail rabbit",
            "coyote",
            "duck",
            "eastern grey squirrel",
            "elk",
            "gray fox",
            "chipmunk",
            "mourning dove",
            "rodent",
            "mule deer",
            "puma",
            "rabbit",
            "raccoon",
            "spotted skunk",
            "steller's jay",
            "striped skunk",
            "tule elk",
            "turkey",
            "turkey vulture",
            "western grey squirrel",
            "western scrub-jay",
            "wild boar",
            "virginia opossum",
        ]

