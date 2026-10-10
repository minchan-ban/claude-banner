#!/usr/bin/env bash
# claude-banner 제거
#  - 셸 설정 파일에서 claude() 래퍼 블록을 삭제 (원본은 .bak 으로 백업)
#  - ~/.claude/banner/ 폴더 삭제
#
# 한 줄 제거:
#   curl -fsSL https://raw.githubusercontent.com/minchan-ban/claude-banner-for-mcban-fans/main/uninstall.sh | bash
#
# 사용법: uninstall.sh [--rc 셸설정파일]
set -euo pipefail

DEST="$HOME/.claude/banner"
RC=""
[[ "${1:-}" == "--rc" ]] && RC="${2:-}"
if [[ -z "$RC" ]]; then
  case "$(basename "${SHELL:-}")" in
    bash) RC="$HOME/.bashrc" ;;
    *)    RC="$HOME/.zshrc" ;;
  esac
fi

BEGIN="# >>> claude-banner >>>"
END="# <<< claude-banner <<<"
if [[ -f "$RC" ]] && grep -qF "$BEGIN" "$RC"; then
  cp "$RC" "$RC.bak"
  awk -v b="$BEGIN" -v e="$END" '$0==b{skip=1} !skip{print} $0==e{skip=0}' "$RC.bak" > "$RC"
  echo "셸 설정에서 제거: $RC (백업: $RC.bak)"
fi

if [[ -d "$DEST" ]]; then
  rm -rf "$DEST"
  echo "삭제: $DEST"
fi

echo "완료. 새 터미널부터 배너가 나오지 않습니다."
