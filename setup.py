from setuptools import setup, find_packages

setup(
    name="pathadder",
    description="A Python library for managing and modifying system paths efficiently. (Wattleflow)",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    author="WattleFlow",
    author_email="wattleflow@outlook.com",
    url="https://github.com/wattleflow/pathadder.git",
    use_scm_version=True,
    setup_requires=["setuptools>=42", "setuptools_scm"],
    packages=find_packages(where="pathadder"),
    package_dir={"": "pathadder"},
    include_package_data=True,
    classifiers=[
        "Development Status :: 5 - Production/Stable",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
        "Programming Language :: Python :: 3.12",
        "Programming Language :: Python :: 3.13",
        "Operating System :: OS Independent",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Libraries",
        "Topic :: Software Development :: Libraries :: Python Modules",
    ],
    python_requires=">=3.7.1",
    install_requires=[],
    extras_require={},
)
