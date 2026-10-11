export const NotifyPlugin = async ({ client, $ }) => {
  return {
    "permission.ask": async ({ title, type, pattern }, output) => {
      if (output.status !== "ask") return;
      const what = Array.isArray(pattern) ? pattern.join(" ") : String(pattern || type);
      const esc = (s: string) =>
        s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
      await $`notify-send -a OpenCode ${esc(`OpenCode: ${title}`)} ${esc(what)}`;
    },
    event: async ({ event }) => {
      if (event.type !== "session.idle") return;

      const sessionID = event.properties.sessionID;

      const { data: session } = await client.session.get({ path: { id: sessionID } });
      if (session?.parentID) return;

      const { data } = await client.session.messages({ path: { id: sessionID } });
      const messages = data ?? [];
      if (!messages.length) return;

      const lastUser = [...messages].reverse().find((m: any) => m.info.role === "user");
      const lastAnswer = [...messages].reverse().find(
        (m: any) => m.info.role === "assistant" && !m.info.summary
      );
      if (!lastAnswer) return;

      const text = lastAnswer.parts
        .filter((p: any) => p.type === "text" && !p.ignored && p.text?.trim())
        .map((p: any) => p.text.trim())
        .join("\n");
      const firstLine = text.split("\n").find((l: string) => l.trim()) ?? "";
      const summary = firstLine.replace(/^[#\-*\s]+/, "").slice(0, 160);

      const start = lastUser?.info.time.created ?? lastAnswer.info.time.created;
      const end = lastAnswer.info.time.completed ?? Date.now();
      const secs = Math.max(0, Math.round((end - start) / 1000));
      const duration = `${String(Math.floor(secs / 60)).padStart(2, "0")}m ${String(secs % 60).padStart(2, "0")}s`;

      let title = "OpenCode";
      try {
        const pane = process.env.TMUX_PANE;
        const cmd = pane
          ? $`tmux display-message -p -t ${pane} '#S'`
          : $`tmux display-message -p '#S'`;
        const out = (await cmd.text()).trim();
        if (out) title = out;
      } catch {}

      const esc = (s: string) =>
        s.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
      const body = summary
        ? `${esc(summary)}\n<i>${duration}</i>`
        : `<i>${duration}</i>`;
      await $`notify-send -a OpenCode ${esc(title)} ${body}`;
    },
  };
};
