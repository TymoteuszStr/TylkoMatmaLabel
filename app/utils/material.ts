import type { MaterialType } from "~/types/database";

export function getMaterialColor(
  type: MaterialType,
): "blue" | "yellow" | "green" | "purple" | "gray" {
  const colors: Record<
    MaterialType,
    "blue" | "yellow" | "green" | "purple" | "gray"
  > = {
    theory: "blue",
    example: "yellow",
    exercise: "green",
    summary: "purple",
  };
  return colors[type as unknown as MaterialType] || "gray";
}

export function getMaterialIcon(type: string) {
  const icons: Record<string, string> = {
    theory: "i-heroicons-book-open",
    example: "i-heroicons-light-bulb",
    exercise: "i-heroicons-pencil-square",
    summary: "i-heroicons-document-text",
  };
  return icons[type] || "i-heroicons-document";
}

export function getMaterialLabel(type: string) {
  const labels: Record<string, string> = {
    theory: "Teoria",
    example: "Przykład",
    exercise: "Ćwiczenie",
    summary: "Podsumowanie",
  };
  return labels[type] || type;
}
