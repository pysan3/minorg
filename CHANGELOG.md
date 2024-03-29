# Changelog

## [2.4.6](https://github.com/pysan3/minorg/compare/v2.4.5...v2.4.6) (2024-02-24)


### Bug Fixes

* **pd2norg:** escape inline modifier content if starts with bar `|` ([4e8a22e](https://github.com/pysan3/minorg/commit/4e8a22ee7a4003e9289293b92884ccfbeedfd9f2))

## [2.4.5](https://github.com/pysan3/minorg/compare/v2.4.4...v2.4.5) (2023-11-10)


### Bug Fixes

* **pd2norg:** detect language of inline code block if exists ([#34](https://github.com/pysan3/minorg/issues/34)) ([3f1bf83](https://github.com/pysan3/minorg/commit/3f1bf83eab22b9a6e7d3c251b62f463c475a41ab)), closes [#32](https://github.com/pysan3/minorg/issues/32)

## [2.4.4](https://github.com/pysan3/minorg/compare/v2.4.3...v2.4.4) (2023-11-09)


### Bug Fixes

* **pd2norg:** use raw `[@embed](https://github.com/embed)` syntax for RawInline ([a706367](https://github.com/pysan3/minorg/commit/a706367bf1ef26cd53ab26ee43e0e94aeb1936c5))

## [2.4.3](https://github.com/pysan3/minorg/compare/v2.4.2...v2.4.3) (2023-11-06)


### Bug Fixes

* **nim_pandoc:** upgrade to nim_pandoc v4 ([ddc089c](https://github.com/pysan3/minorg/commit/ddc089ca396fbf073abb456f5ed554a66d1286b1))
* **pd2norg:** refactor code to manage newlines ([ec63867](https://github.com/pysan3/minorg/commit/ec6386794416d1593dd1678e94643caf0dffd69b)), closes [#29](https://github.com/pysan3/minorg/issues/29)

## [2.4.2](https://github.com/pysan3/minorg/compare/v2.4.1...v2.4.2) (2023-11-04)


### Bug Fixes

* **PDTable:** support table with newlines to separate the block ([407a7f6](https://github.com/pysan3/minorg/commit/407a7f62d5aa3c169287d1e42b0e9400c2dfa110))

## [2.4.1](https://github.com/pysan3/minorg/compare/v2.4.0...v2.4.1) (2023-11-04)


### Bug Fixes

* **minorg:** extract version number from nimble file ([7bea1d5](https://github.com/pysan3/minorg/commit/7bea1d5d8bc0eb1e2cf744e9c41dc5c54d69f565))

## [2.4.0](https://github.com/pysan3/minorg/compare/v2.3.0...v2.4.0) (2023-11-03)


### Features

* **PDTable:** implement PDTable parser ([#25](https://github.com/pysan3/minorg/issues/25)) ([d14b639](https://github.com/pysan3/minorg/commit/d14b639a70b63e7c73297c152e1d0df7384a6a91))

## [2.3.0](https://github.com/pysan3/minorg/compare/v2.2.0...v2.3.0) (2023-11-02)


### Features

* **pd2norg:** implement remaining features except for tables ([#23](https://github.com/pysan3/minorg/issues/23)) ([0f4c78b](https://github.com/pysan3/minorg/commit/0f4c78b540b086621c8e7ab62ff98fc3ea677512))

## [2.2.0](https://github.com/pysan3/minorg/compare/v2.1.1...v2.2.0) (2023-11-01)


### Features

* **obsidian:** add support for obsidian wikilink format ([#21](https://github.com/pysan3/minorg/issues/21)) ([6a191d3](https://github.com/pysan3/minorg/commit/6a191d3a5096a6fcf9cd5c2fe8bb9c03ce66886c))

## [2.1.1](https://github.com/pysan3/minorg/compare/v2.1.0...v2.1.1) (2023-10-31)


### Bug Fixes

* **cligen:** upgrade cligen to display correct version number ([8ad4001](https://github.com/pysan3/minorg/commit/8ad40016383875d7fc1f5c498fa27c80a17bd174))

## [2.1.0](https://github.com/pysan3/minorg/compare/v2.0.2...v2.1.0) (2023-10-31)


### Features

* **pd2norg:** add option to parse obsidian files ([#18](https://github.com/pysan3/minorg/issues/18)) ([25fd918](https://github.com/pysan3/minorg/commit/25fd9189879b29072e2818ec276cfe05a21fcfb0))

## [2.0.2](https://github.com/pysan3/minorg/compare/v2.0.1...v2.0.2) (2023-10-31)


### Bug Fixes

* **pathlib:** remove deprecated functions and use nim-regex ([#16](https://github.com/pysan3/minorg/issues/16)) ([8886a2c](https://github.com/pysan3/minorg/commit/8886a2c9664915351eb9ea98b3a856460b0a5d58))

## [2.0.1](https://github.com/pysan3/minorg/compare/v2.0.0...v2.0.1) (2023-10-31)


### Bug Fixes

* **action:** migration from `nim_norg` ([d6cd11f](https://github.com/pysan3/minorg/commit/d6cd11fbb63870917f9762adeeb6e6159dc1db8b))

## [2.0.0](https://github.com/pysan3/minorg/compare/v1.2.0...v2.0.0) (2023-10-31)


### ⚠ BREAKING CHANGES

* **minorg:** rename to minorg ([#13](https://github.com/pysan3/minorg/issues/13))

### Features

* **minorg:** rename to minorg ([#13](https://github.com/pysan3/minorg/issues/13)) ([03bfd90](https://github.com/pysan3/minorg/commit/03bfd9033f2fe958d1d651f71fe628d975e93274))

## [1.2.0](https://github.com/pysan3/nim_norg/compare/v1.1.2...v1.2.0) (2023-10-31)


### Features

* **pd2norg:** improve todo item detection from markdown ([#11](https://github.com/pysan3/nim_norg/issues/11)) ([a730d70](https://github.com/pysan3/nim_norg/commit/a730d700e47f119784d6ae04a5b14777efb1a07e))

## [1.1.2](https://github.com/pysan3/nim_norg/compare/v1.1.1...v1.1.2) (2023-10-31)


### Bug Fixes

* **pd2norg:** improve softbreak bug in norg parser ([#9](https://github.com/pysan3/nim_norg/issues/9)) ([6f4d484](https://github.com/pysan3/nim_norg/commit/6f4d484a21473d0748779f86f3b45d1da932f894))

## [1.1.1](https://github.com/pysan3/nim_norg/compare/v1.1.0...v1.1.1) (2023-10-30)


### Bug Fixes

* **action:** update release-please to update nimble version ([832df95](https://github.com/pysan3/nim_norg/commit/832df95a8cccb496f26fd27931ca3663dbd6c031))

## [1.1.0](https://github.com/pysan3/nim_norg/compare/v1.0.1...v1.1.0) (2023-10-30)


### Features

* **cli:** add `-o` flag to specify output file ([#6](https://github.com/pysan3/nim_norg/issues/6)) ([3741c76](https://github.com/pysan3/nim_norg/commit/3741c767d5362706d50b9dbd292ff08dbaad6725))

## [1.0.1](https://github.com/pysan3/nim_norg/compare/v1.0.0...v1.0.1) (2023-10-30)


### Bug Fixes

* **ci:** hope this makes binary releases with release please ([#4](https://github.com/pysan3/nim_norg/issues/4)) ([b603b9f](https://github.com/pysan3/nim_norg/commit/b603b9f6d99b47ebabdff524fd33c1d669fd2e53))

## 1.0.0 (2023-10-30)


### Bug Fixes

* **action:** delete lock file in windows env ([9cf8f9a](https://github.com/pysan3/nim_norg/commit/9cf8f9a16550549e1009986eb837dc96e91687c2))
* **action:** delete lock file in windows env ([19c995e](https://github.com/pysan3/nim_norg/commit/19c995e7a16efa7fafbbf346eb755d9ab174f7d6))
* **action:** delete unnecessary arguments in ci ([4af8b45](https://github.com/pysan3/nim_norg/commit/4af8b45c2dbe021451390f5d453615fb37c3f4a6))
* **action:** fix installation in doc gen action ([ae842bf](https://github.com/pysan3/nim_norg/commit/ae842bf5d0539b73fd1107acc5ec2df40388b6e7))
* **action:** fix key name typo ([16240f5](https://github.com/pysan3/nim_norg/commit/16240f5688cea4e367af8cedb61615376a9d8dac))
* **action:** fix path of generated tar file ([00b1b80](https://github.com/pysan3/nim_norg/commit/00b1b8027e6df7dbd5dea8d16afacf964c6a0c5b))
* **action:** hardcode nim version for binary compilation ([b4df2bd](https://github.com/pysan3/nim_norg/commit/b4df2bde09513a3941431d37b5a81c2041b8a13e))
* **action:** install apt dependencies with gh action ([86949f6](https://github.com/pysan3/nim_norg/commit/86949f649b2a27628281fae99b9f7b3b432e5f35))
* **action:** install git dependencies beforehand ([cf20afe](https://github.com/pysan3/nim_norg/commit/cf20afe7bad58c41f3783c0574f14392250fbd17))
* **action:** release binary on new tag release ([#3](https://github.com/pysan3/nim_norg/issues/3)) ([ccc1c25](https://github.com/pysan3/nim_norg/commit/ccc1c25db70d19923dfa0a359e84a78abbced5fc))
* **action:** remove unnecessary matrix ([48faac4](https://github.com/pysan3/nim_norg/commit/48faac4d754115d3631f5886ca8c1a996a2e893e))
* **action:** upload lock file and ignore it in windows env ([9faa514](https://github.com/pysan3/nim_norg/commit/9faa514243729ac8d33deaabb7a8231bad3aa2e1))
* **action:** windows cannot remove file with `rm` ([5977464](https://github.com/pysan3/nim_norg/commit/59774645458941d436307d7fdd5cba0ff45823a4))
* **nimble:** add lock file and delete unnecessary files ([#1](https://github.com/pysan3/nim_norg/issues/1)) ([db5d559](https://github.com/pysan3/nim_norg/commit/db5d559ff6ddfe5ece3b34a1efaf28aeef8b68c4))
* **nimble:** do not compress binaries ([e21e34d](https://github.com/pysan3/nim_norg/commit/e21e34d82035a3f5976c7d816481931da96c46d9))
* **nimble:** force overwrite on all nimble commands ([03e6a9a](https://github.com/pysan3/nim_norg/commit/03e6a9abbf652b01ec45499f23c483a617372a66))
* **nimble:** install cligen separately ([d514c62](https://github.com/pysan3/nim_norg/commit/d514c62e10f210bd2a35fd305dc9c7ff806229c0))
* **nimble:** nimble checksum does not match on windows environment ([55f6f0a](https://github.com/pysan3/nim_norg/commit/55f6f0a55d7ff684c67645e0cae5d2fbff1a334a))
* **nimble:** verbose all outputs ([201ae0d](https://github.com/pysan3/nim_norg/commit/201ae0d7aaea70fcafb55b77e2e5b8f928480bf6))
