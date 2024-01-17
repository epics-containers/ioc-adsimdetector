This config folder is where the generic IOC container will look
for configuration files. These configuration files are used to
bootstrap a unique IOC instance.

For this reason this folder is intended to be mounted over at container
runtime. The mounted folder should the IOC instance's config folder.
