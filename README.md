![VisSE Logo](https://www.ucm.es/visse/file/logo_visse_color/?ver)

# VisSE

The [VisSE project](https://www.ucm.es/visse) ("Visualizando la SignoEscritura",
"Visualizing SignWriting") aims to develop tools that ease the use and
understanding of [SignWriting](https://signwriting.org/) in the digital world.
SignWriting is a system for visually transcribing sign languages into a 2D page,
i.e. a writing system for sign languages.

This repository collects the different software results of the project, along
with instructions for their use.

- [Quevedo](https://github.com/agarsev/quevedo): a python tool for the
    annotation of images with complex semantics, dataset organization, neural
    network training and expert system building.
- [VisSE Corpus](https://github.com/agarsev/visse-corpus): a corpus of handwritten
    SignWriting annotations of Spanish Sign Language, in Quevedo dataset format,
    with trained neural networks and recognition pipelines.
- [VisSE App](https://github.com/agarsev/visse-app): a progressive web application for
    the explanation of handwritten SignWriting instances. It identifies the
    different components of the trascription, and gives a textual explanation of
    their meaning as well as a 3D model of the hands involved.

## Usage

### In production

Use the `setup.sh` script to deploy the project.

### For development

This repository is a [meta](https://github.com/mateodelnorte/meta) repository.
Clone it with `meta git clone` or use `meta git update` to get the different
dependencies in this directory.

## Acknowledgements

The project "Visualizando la SignoEscritura" (Visualizing SignWriting),
reference number PR2014_19/01, was developed in the Faculty of Computer Science
of Universidad Complutense de Madrid and funded by Indra and Fundación Universia
in the IV call for funding aid for research projects with application to the
development of accessible technologies.

We want to acknowledge the collaboration of the signing community, especially
the Spanish Sign Language teachers at Idiomas Complutense and Fundación CNSE.

### Team

- [Antonio F. G. Sevilla](https://github.com/agarsev) <afgs@ucm.es>
- [Alberto Díaz Esteban](https://www.ucm.es/directorio?id=20069)
- [Jose María Lahoz-Bengoechea](https://ucm.es/lengespyteoliter/cv-lahoz-bengoechea-jose-maria)
