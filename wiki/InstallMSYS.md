# Installation in Msys2 environment under Windows

- Add repository to `pacman` config, this needs to be done only once

  ```
  echo -e "[pacman]\nSigLevel = Optional TrustAll\nServer = https://dl.bintray.com/igagis/msys2/mingw/$arch" >> /etc/pacman.conf
  ```

- Install **prorab**

  ```
  pacman -Sy prorab
  ```
