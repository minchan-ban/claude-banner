#!/usr/bin/env bash
# claude-banner 설치
#  - ~/.claude/banner/ 에 배너 스크립트·사진·설정 파일을 복사
#  - 셸 설정 파일(~/.zshrc 또는 ~/.bashrc)에 claude() 래퍼 함수를 추가
#  - chafa / figlet 이 없으면 Homebrew 로 설치
#
# 한 줄 설치:
#   curl -fsSL https://raw.githubusercontent.com/minchan-ban/claude-banner-for-mcban-fans/main/install.sh | bash
# 옵션 전달:
#   curl -fsSL .../install.sh | bash -s -- --photo ~/me.jpg
#
# 사용법: install.sh [--photo 사진경로] [--rc 셸설정파일]
set -euo pipefail

RAW="${CLAUDE_BANNER_RAW:-https://raw.githubusercontent.com/minchan-ban/claude-banner-for-mcban-fans/main}"
DEST="$HOME/.claude/banner"
PHOTO_ARG=""
RC=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --photo) PHOTO_ARG="$2"; shift 2 ;;
    --rc)    RC="$2"; shift 2 ;;
    -h|--help) sed -n 2,12p "$0"; exit 0 ;;
    *) echo "알 수 없는 옵션: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$RC" ]]; then
  case "$(basename "${SHELL:-}")" in
    bash) RC="$HOME/.bashrc" ;;
    *)    RC="$HOME/.zshrc" ;;
  esac
fi

# 레포를 클론해서 실행했으면 로컬 파일을, `curl | bash` 로 실행했으면 GitHub 에서 받은 파일을 쓴다
SRC=""
if [[ -n "${BASH_SOURCE[0]:-}" && -f "${BASH_SOURCE[0]}" ]]; then
  here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  [[ -f "$here/startup-banner.sh" ]] && SRC="$here"
fi
if [[ -z "$SRC" ]]; then
  SRC="$(mktemp -d)"
  trap 'rm -rf "$SRC"' EXIT
  mkdir -p "$SRC/assets"
  echo "파일 내려받는 중..."
  for f in startup-banner.sh config.example.sh assets/banner-photo.jpeg; do
    curl -fsSL "$RAW/$f" -o "$SRC/$f"
  done
fi

PHOTO_SRC="${PHOTO_ARG:-$SRC/assets/banner-photo.jpeg}"
[[ -f "$PHOTO_SRC" ]] || { echo "사진을 찾을 수 없습니다: $PHOTO_SRC" >&2; exit 1; }

# 의존성: chafa(사진 → 픽셀아트), figlet(큰 글자)
missing=()
for dep in chafa figlet; do
  command -v "$dep" >/dev/null 2>&1 || missing+=("$dep")
done
if [[ ${#missing[@]} -gt 0 ]]; then
  BREW="$(command -v brew || true)"
  [[ -z "$BREW" && -x /opt/homebrew/bin/brew ]] && BREW=/opt/homebrew/bin/brew
  [[ -z "$BREW" && -x /usr/local/bin/brew ]] && BREW=/usr/local/bin/brew
  if [[ -n "$BREW" ]]; then
    echo "${missing[*]} 설치 중 (Homebrew)..."
    "$BREW" install "${missing[@]}"
  else
    echo "⚠️  ${missing[*]} 가 없습니다. 아래 중 하나로 설치한 뒤 다시 실행하세요."
    echo "   macOS : Homebrew 설치(https://brew.sh) 후 brew install ${missing[*]}"
    echo "   Linux : sudo apt install ${missing[*]}"
  fi
fi

mkdir -p "$DEST"
cp "$SRC/startup-banner.sh" "$DEST/startup-banner.sh"
chmod +x "$DEST/startup-banner.sh"
cp "$PHOTO_SRC" "$DEST/banner-photo.jpeg"
if [[ -f "$DEST/config.sh" ]]; then
  echo "기존 설정 유지: $DEST/config.sh"
else
  cp "$SRC/config.example.sh" "$DEST/config.sh"
fi

BEGIN="# >>> claude-banner >>>"
END="# <<< claude-banner <<<"
if [[ -f "$RC" ]] && grep -qF "$BEGIN" "$RC"; then
  echo "셸 설정에 이미 등록됨: $RC"
else
  cat >> "$RC" <<EOF

$BEGIN
# \`claude\` 실행 시 배너를 먼저 띄운 뒤 실제 claude 를 실행한다.
# 배너 끄려면: NO_CLAUDE_BANNER=1 claude
claude() {
  if [[ -z "\$NO_CLAUDE_BANNER" && -f "\$HOME/.claude/banner/startup-banner.sh" ]]; then
    bash "\$HOME/.claude/banner/startup-banner.sh"
  fi
  command claude "\$@"
}
$END
EOF
  echo "셸 설정에 등록: $RC"
fi

command -v claude >/dev/null 2>&1 || echo "ℹ️  Claude Code 가 아직 없습니다: https://claude.com/claude-code"

echo
echo "✅ 설치 완료! 터미널을 새로 열고 claude 를 입력하세요."
