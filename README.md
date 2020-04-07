## dockerfiles-strongswan

This image can be used to setup an IPsec tunnel. For proper usage ensure:

- Container is using "host" networking
- Container is privileged
- Add `SYS_MODULE` capabilities.
- /lib/modules on the host side is mounted on the containers /lib/modules

Then you can mount your charon or other strongswan configs as needed inside the image.
