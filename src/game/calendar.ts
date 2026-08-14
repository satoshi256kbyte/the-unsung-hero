export function dayOfWeek(turn: number): number {
  return (turn - 1) % 7;
}

export function isWeekend(turn: number): boolean {
  const day = dayOfWeek(turn);
  return day === 5 || day === 6;
}
