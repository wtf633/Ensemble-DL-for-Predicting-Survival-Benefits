<p align="center">
  <h2 align="center"><img width="5%" src="./fig/logo.png" /> CT-Based Ensemble Deep Learning for Predicting Survival Benefits of Immune Checkpoint Inhibitors in Unresectable Hepatocellular Carcinoma: A Multicenter Study</h2>
</p>

## Our article is in the submission stage...
![Official](https://img.shields.io/badge/Official-Yes-blue)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

## Overview

This study proposes an ensemble deep learning framework to predict survival outcomes (overall survival [OS] and progression-free survival [PFS]) for patients with unresectable hepatocellular carcinoma (HCC) receiving immune checkpoint inhibitors (ICIs). The framework leverages deep learning features extracted from baseline CT images, directly predicting survival outcomes and fully exploiting imaging data. To enhance model robustness and generalizability, we employed an ensemble learning strategy. This approach integrates three complementary neural networks, each with distinct architectural characteristics. The ensemble framework consists of three 3D  neural networks: a standard CNN (network 1), a hybrid CNN incorporating supervised and unsupervised learning (network 2), and a CNN-Transformer model (network 3). Network 1 is a traditional 3D-CNN architecture designed to extract relevant features from CT images. Network 2 combines supervised and unsupervised learning components, aiming to improve feature extraction and generalization by learning both discriminative and latent representations. Network 3 integrates the strengths of CNNs and transformers, leveraging CNNs for local spatial pattern recognition and transformers for modeling long-range dependencies. The ensemble framework combines the predictions from these three sub-models using a weighted voting strategy. The weights are determined based on the performance of each sub-model on a validation set. This approach allows the ensemble to leverage the strengths of each individual model and mitigate their weaknesses. By employing this ensemble deep learning framework, we aim to provide a more accurate and reliable tool for predicting survival outcomes in patients with unresectable HCC receiving ICIs. This information can aid in clinical decision-making and potentially improve patient outcomes.
<br></br>
<img width="95%" src="./fig/1.png" />

## Table of Contents

- [Installation](#installation)
- [Dataset](#dataset)
- [Model](#model)
- [Results](#results)
- [License](#license)

## Installation

Please follow the guide to install and set up the project.

```bash
# Clone the repository
git clone https://github.com/wtf633/Whole-liver-DeepL-Model.git

# Create conda environment
conda env create -f environment.yml
conda activate your_environment_name
```
## Dataset

Data related to this study, including de-identified participant data with the accompanying data dictionary, original CT images, study protocol, and statistical analysis plan, will be made available to the scientific community upon publication. Requests for these data should be directed to the corresponding authors and must be reasonable. A signed data use agreement and institutional review board approval will be required before the release of any research data.

## Model
<img width="70%" src="./fig/models.png" />

* **Network 1 (EfficientNet B1 Model):** This subnetwork uses the EfficientNet B1 convolutional neural network (CNN) for supervised learning (Figure A).<br>
* **Network 2 (Hybrid Supervised-Unsupervised Model):** This subnetwork employs a two-stage approach (Figure B).<br>
* **Network 3 (CNN-Transformer Model):** This subnetwork adopts a CNN-Transformer architecture based on multi-plane and multi-slice Transformer networks (Figure C).

## Results

#### Ablation analysis to optimize Network 1 to Network 3in overall survival and progression-free survival
<img width="80%" src="./results/res1.PNG" />


#### Performance comparison between standalone imaging models (Network 1 to Network 3) and Ensemble DL in overall survival and progression-free survival
<img width="80%" src="./results/res2.PNG" />

#### Grad-CAM Attention: Heatmaps illustrate the key image regions that most influence the sub-models' predictions. While all sub-networks focus on the tumor, each emphasizes distinct features, underscoring their complementary nature.
<img width="75%" src="./results/cam.png" />

*It is worth noting that the two tables above are only part of our results. Please refer to the full text and supplementary materials for other results.

## License
This project is licensed under the MIT License
