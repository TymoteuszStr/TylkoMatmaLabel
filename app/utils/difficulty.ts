import type { DifficultyLevel } from "~/types/database";

export function getDifficultyColor(
  level: string,
): "green" | "yellow" | "red" | "gray" {
  const colors: Record<DifficultyLevel, "green" | "yellow" | "red" | "gray"> = {
    basic: "green",
    intermediate: "yellow",
    advanced: "red",
  };
  return colors[level as unknown as DifficultyLevel] || "gray";
}

export function getDifficultyLabel(level: string): string {
  const labels: Record<string, string> = {
    basic: "Podstawowy",
    intermediate: "Średniozaawansowany",
    advanced: "Zaawansowany",
  };
  return labels[level] || level;
}
