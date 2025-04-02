from setuptools import setup, find_packages

setup(
    name="pathadder",
    version="0.0.0.1",
    description="A Python library for managing and modifying system paths efficiently. (Wattleflow)",
    long_description=open("README.md").read(),
    long_description_content_type="text/markdown",
    author="WattleFlow",
    author_email="wattleflow@outlook.com",
    url="https://github.com/wattleflow/pathadder.git",
    license="Apache-2.0",
    packages=find_packages(where="."),
    package_dir={"": "."},
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
        "License :: OSI Approved :: Apache Software License",
    ],
    python_requires=">=3.7.1",
    install_requires=[
        # Dependencies
    ],
    extras_require={
        # Optional dependencies
    },
)
