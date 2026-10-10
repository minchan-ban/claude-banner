#!/usr/bin/env bash
# claude-banner 설치
#  - ~/.claude/banner/ 에 배너 스크립트·사진·설정 파일을 복사
#  - 셸 설정 파일(~/.zshrc 또는 ~/.bashrc)에 claude() 래퍼 함수를 추가
#
# 사용법: ./install.sh [--photo 사진경로] [--rc 셸설정파일]
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.claude/banner"
PHOTO_SRC="$SRC/assets/banner-photo.jpeg"
RC=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --photo) PHOTO_SRC="$2"; shift 2 ;;
    --rc)    RC="$2"; shift 2 ;;
    -h|--help) sed -n 2,6p "$0"; exit 0 ;;
    *) echo "알 수 없는 옵션: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$RC" ]]; then
  case "$(basename "${SHELL:-}")" in
    bash) RC="$HOME/.bashrc" ;;
    *)    RC="$HOME/.zshrc" ;;
  esac
fi

[[ -f "$PHOTO_SRC" ]] || { echo "사진을 찾을 수 없습니다: $PHOTO_SRC" >&2; exit 1; }

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

for dep in chafa figlet; do
  command -v "$dep" >/dev/null 2>&1 || echo "⚠️  $dep 가 없습니다. 설치: brew install $dep"
done

echo "완료. 새 터미널을 열거나 'source $RC' 후 claude 를 실행하세요."
