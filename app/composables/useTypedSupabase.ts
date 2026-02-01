import type { Database } from "~/types/database";
import type { SupabaseClient } from "@supabase/supabase-js";

export const useTypedSupabaseClient = () => {
  const client = useSupabaseClient();
  return client as unknown as SupabaseClient<Database>;
};
