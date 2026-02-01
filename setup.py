from setuptools import setup

setup(
    name="nodup",
    version="1.1.0",
    description="Find and optionally delete duplicate files by hash",
    author="Your Name",
    py_modules=["app"],
    python_requires=">=3.7",
    entry_points={
        "console_scripts": [
            "nodup=app:main",
        ]
    },
    include_package_data=True,  
)

