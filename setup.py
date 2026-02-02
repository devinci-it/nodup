from setuptools import setup, find_packages

setup(
    name='nodup',
    version='1.2.0',
    description="Find and optionally delete duplicate files by hash",
    author="Your Name",
    packages=find_packages(where='src'),
    package_dir={'': 'src'},  
    
    # Entry point for command-line tool
    entry_points={
        'console_scripts': [
            'nodup=nodup.app:main',  
        ]
    },

    # Core dependencies for your package
    install_requires=[
        'argcomplete',  
        'pipenv' ,   
    ],

    
    include_package_data=True,
    package_data={
         'nodup': ['templates/*.tmpl'],
    },

    # Development dependencies for testing, building, etc.
    extras_require={
        'dev': [
            'setuptools', 
            'wheel',     
            'pytest',   
            'pipenv',  
           
        ],
    },

    classifiers=[
        'Programming Language :: Python :: 3',
        'License :: OSI Approved :: MIT License',
        'Operating System :: OS Independent',
    ],

    python_requires='>=3.7',
)
