#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
# Claude Code 시작 배너  (느와르 / monochrome)
#  - 사진을 chafa 로 픽셀아트로 출력 (터미널 폭에 맞춰 최대 해상도)
#  - 문구를 figlet 으로 사진 폭 기준 중앙정렬
#  - 무지개 대신 흑백 고대비(노이르)로 명암 위계만 줌
#
# 아래 값은 기본값입니다. 바꾸려면 이 파일을 고치지 말고
# config.sh (기본 위치: 이 스크립트와 같은 폴더) 에서 덮어쓰세요.
# ─────────────────────────────────────────────────────────────

BANNER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PHOTO="$BANNER_DIR/banner-photo.jpeg"       # 픽셀아트로 띄울 사진
PHOTO_WIDTH="auto"                          # auto = 터미널 폭에 꽉 채워 최대 해상도. 고정하려면 숫자(예: 80)
MAX_WIDTH=100                               # auto 일 때 상한
# 문구 (순서대로 / 비우면 해당 줄 생략)
LINES=(
  "MC BAN'S"
  "FUN"
  "COOL"
  "SEXY"
  "CLAUDE"
)
# 각 줄 폰트 — 위/아래는 shadow(크게), 중간 3줄은 smshadow(작게). 기울임 없음.
FONTS=( shadow smshadow smshadow smshadow shadow )
# 각 줄 색 "R;G;B". CLAUDE 는 주황색.
COLORS=(
  "255;255;255"   # MC BAN'S  흰색
  "160;160;160"   # FUN       회색
  "175;175;175"   # COOL
  "190;190;190"   # SEXY
  "255;140;0"     # CLAUDE    주황
)

# 사용자 설정으로 덮어쓰기
CONFIG="${CLAUDE_BANNER_CONFIG:-$BANNER_DIR/config.sh}"
# shellcheck source=/dev/null
[[ -f "$CONFIG" ]] && source "$CONFIG"

# homebrew 경로 보장
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# 출력 폭(W) 계산 — 사진과 글자 모두 이 폭 기준으로 중앙정렬
if [[ "$PHOTO_WIDTH" == "auto" ]]; then
  COLS="$(tput cols 2>/dev/null || echo 80)"
  W=$(( COLS - 2 )); (( W < 20 )) && W=20
  (( W > MAX_WIDTH )) && W=$MAX_WIDTH
else
  W="$PHOTO_WIDTH"
fi

echo

# 1) 사진 → 픽셀아트 (폭 W)
if command -v chafa >/dev/null 2>&1 && [[ -f "$PHOTO" ]]; then
  chafa -f symbols --symbols all --work 9 --size "${W}x${W}" "$PHOTO"
  echo
fi

# 2) 문구 — 줄별 폰트/색, figlet 중앙정렬
if command -v figlet >/dev/null 2>&1; then
  i=0
  for line in "${LINES[@]}"; do
    [[ -z "$line" ]] && { i=$((i+1)); continue; }
    f="${FONTS[$i]:-shadow}"
    c="${COLORS[$i]:-255;255;255}"
    printf '\033[1;38;2;%sm' "$c"                      # 24bit 색 + bold
    figlet -f "$f" -w "$W" -c "$line" 2>/dev/null || figlet -w "$W" -c "$line"
    printf '\033[0m'
    i=$((i+1))
  done
else
  for line in "${LINES[@]}"; do printf '%*s\n' $(( (W+${#line})/2 )) "$line"; done
fi

echo
