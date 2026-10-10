# claude-banner

`claude` 명령어를 실행할 때 내 사진을 픽셀아트로 띄우고, 그 아래에 큰 글자 문구를 출력하는 [Claude Code](https://claude.com/claude-code) 시작 배너입니다.

A noir-style startup banner for Claude Code: renders your photo as terminal pixel art with big figlet text before `claude` launches.

![claude-banner screenshot](assets/screenshot.png)

<sub>스크린샷은 웹 글꼴이 지원하는 문자로 다시 그린 이미지라서, 실제 터미널에서는 더 촘촘한 블록 문자로 출력됩니다.</sub>

## 동작 방식

- `claude()` 셸 함수가 원래 `claude` 명령어를 감쌉니다.
- 함수는 배너 스크립트를 먼저 실행하고, 그다음 실제 `claude`를 그대로 실행합니다. 인자도 그대로 전달하므로 `claude -p`, `claude --resume` 등은 평소와 똑같이 작동합니다.
- 사진은 [chafa](https://hpjansson.org/chafa/)로 터미널 폭에 맞춰 픽셀아트로 그리고, 문구는 [figlet](http://www.figlet.org/)으로 중앙 정렬해서 그립니다.
- 셸 함수이기 때문에 터미널에서 직접 입력할 때만 배너가 나옵니다. 스크립트나 자동화 도구가 `claude`를 실행할 때는 나오지 않습니다.

## 요구 사항

- macOS 또는 Linux, zsh 또는 bash
- 24비트 컬러를 지원하는 터미널 (iTerm2, Warp, Ghostty, WezTerm 등)
- `chafa`, `figlet`

```bash
brew install chafa figlet
```

## 설치

```bash
git clone https://github.com/minchan-ban/claude-banner-for-mcban-fans.git
cd claude-banner-for-mcban-fans
./install.sh                       # 기본 사진으로 설치
./install.sh --photo ~/me.jpg      # 내 사진으로 설치
```

설치 스크립트는 다음 작업을 합니다.

- `~/.claude/banner/`에 `startup-banner.sh`, `banner-photo.jpeg`, `config.sh`를 복사합니다. `config.sh`가 이미 있으면 덮어쓰지 않습니다.
- 셸 설정 파일(`~/.zshrc`, bash라면 `~/.bashrc`)에 `claude()` 함수를 추가합니다. 이미 추가되어 있으면 다시 추가하지 않습니다. 다른 파일에 넣으려면 `--rc <파일>`을 지정합니다.

새 터미널을 열고 `claude`를 실행하면 배너가 나옵니다.

## 설정

`~/.claude/banner/config.sh`에서 바꾸고 싶은 값만 주석을 풀어서 고칩니다.

| 변수 | 설명 | 기본값 |
| --- | --- | --- |
| `PHOTO` | 픽셀아트로 띄울 사진 경로 | `~/.claude/banner/banner-photo.jpeg` |
| `PHOTO_WIDTH` | `auto`면 터미널 폭에 맞춤, 숫자면 고정 폭 | `auto` |
| `MAX_WIDTH` | `auto`일 때 최대 폭 | `100` |
| `LINES` | 출력할 문구 배열 (빈 문자열은 건너뜀) | `MC BAN'S` `FUN` `COOL` `SEXY` `CLAUDE` |
| `FONTS` | 줄마다 사용할 figlet 폰트 | `shadow` `smshadow` ×3 `shadow` |
| `COLORS` | 줄마다 사용할 색 (`"R;G;B"`) | 흰색 → 회색 3단계 → 주황 |

사용 가능한 폰트는 `ls "$(figlet -I2)"`로 확인할 수 있습니다. 설정 파일을 다른 곳에 두려면 `CLAUDE_BANNER_CONFIG` 환경 변수로 경로를 지정합니다.

## 배너 끄기

- 한 번만 끄기: `NO_CLAUDE_BANNER=1 claude`
- 완전히 제거하기: `./uninstall.sh`

`uninstall.sh`는 셸 설정 파일에서 `claude-banner` 블록만 지우고(원본은 `.bak`으로 백업), `~/.claude/banner/` 폴더를 삭제합니다.

## 파일 구성

```
claude-banner-for-mcban-fans/
├── startup-banner.sh   # 배너 본체
├── config.example.sh   # 설정 예시 (설치 시 config.sh 로 복사)
├── install.sh
├── uninstall.sh
└── assets/
    ├── banner-photo.jpeg   # 기본 사진
    └── screenshot.png      # README 스크린샷
```

## 라이선스

[MIT](LICENSE). 단, `assets/banner-photo.jpeg`는 MIT 라이선스 대상이 아니며 작성자의 초상입니다. 배너를 쓸 때는 본인 사진으로 바꿔서 사용해 주세요.
