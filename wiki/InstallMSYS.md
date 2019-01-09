# Installation in Msys2 environment under Windows

- Add repository to `pacman` config, this needs to be done only once

  ```
  echo -e '[igagis_msys]\nSigLevel = Optional TrustAll\nServer = https://dl.bintray.com/igagis/msys2/msys' >> /etc/pacman.conf
  echo -e '[igagis_mingw64]\nSigLevel = Optional TrustAll\nServer = https://dl.bintray.com/igagis/msys2/mingw64' >> /etc/pacman.conf
  echo -e '[igagis_mingw32]\nSigLevel = Optional TrustAll\nServer = https://dl.bintray.com/igagis/msys2/mingw32' >> /etc/pacman.conf
  ```

- Install **prorab**

  ```
  pacman -Sy prorab
  ```
