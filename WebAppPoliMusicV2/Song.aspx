<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Song.aspx.cs" Inherits="WebAppPoliMusicV2.Song" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>PoliMusic &middot; Canciones</title>
    <style type="text/css">
        :root {
            --bg: #030303;
            --surface: #212121;
            --surface-2: #181818;
            --line: #2a2a2a;
            --text: #ffffff;
            --muted: #aaaaaa;
            --muted-2: #6e6e6e;
            --accent: #ff0000;
        }

        * { box-sizing: border-box; }

        html, body { margin: 0; padding: 0; }

        body {
            background: var(--bg);
            color: var(--text);
            font-family: "Segoe UI", Roboto, "Helvetica Neue", Helvetica, Arial, sans-serif;
            font-size: 14px;
            -webkit-font-smoothing: antialiased;
        }

        a { color: inherit; text-decoration: none; }
        svg { display: block; }

        /* ---------- Top bar ---------- */
        .topbar {
            position: fixed;
            top: 0; left: 0; right: 0;
            height: 64px;
            z-index: 50;
            display: flex;
            align-items: center;
            gap: 24px;
            padding: 0 22px;
            background: var(--bg);
            border-bottom: 1px solid #131313;
        }

        .brand { display: flex; align-items: center; gap: 10px; white-space: nowrap; }
        .brand .logo {
            width: 34px; height: 34px;
            border-radius: 50%;
            background: var(--accent);
            display: flex; align-items: center; justify-content: center;
        }
        .brand .name { font-size: 20px; font-weight: 700; letter-spacing: -.4px; }

        .search-wrap { flex: 1; min-width: 0; display: flex; justify-content: center; }
        .search-box {
            display: flex; align-items: center;
            width: 100%; max-width: 560px; min-width: 0; height: 42px;
            padding: 0 5px 0 18px;
            background: #151515;
            border: 1px solid var(--line);
            border-radius: 22px;
            transition: border-color .15s, background .15s;
        }
        .search-box:focus-within { background: #1c1c1c; border-color: #4a4a4a; }
        .search-box input[type="text"] {
            flex: 1;
            min-width: 0;
            background: transparent;
            border: 0;
            outline: none;
            color: var(--text);
            font-size: 14px;
            font-family: inherit;
            padding: 0;
        }
        .search-box input[type="text"]::placeholder { color: #8c8c8c; }
        .search-btn {
            flex: 0 0 auto;
            height: 32px;
            padding: 0 16px;
            border: 0;
            border-radius: 16px;
            background: #2f2f2f;
            color: #f1f1f1;
            font-size: 12px;
            font-weight: 600;
            font-family: inherit;
            cursor: pointer;
            transition: background .15s, color .15s;
        }
        .search-btn:hover { background: var(--accent); color: #fff; }

        .user-area { display: flex; align-items: center; gap: 12px; }
        .user-chip { display: flex; align-items: center; gap: 9px; }
        .avatar {
            width: 32px; height: 32px;
            border-radius: 50%;
            object-fit: cover;
            border: 1px solid #3a3a3a;
        }
        .user-name { font-size: 13px; color: #ededed; max-width: 140px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
        .badge {
            font-size: 9px;
            font-weight: 700;
            letter-spacing: .6px;
            text-transform: uppercase;
            padding: 2px 6px;
            border-radius: 4px;
            background: rgba(255, 0, 0, .16);
            color: #ff6b6b;
            border: 1px solid rgba(255, 0, 0, .35);
        }
        .logout {
            display: inline-flex;
            align-items: center;
            gap: 7px;
            font-size: 12px;
            font-weight: 600;
            color: #cfcfcf;
            padding: 8px 15px;
            border: 1px solid #3a3a3a;
            border-radius: 18px;
            cursor: pointer;
            transition: color .15s, border-color .15s, background .15s;
        }
        .logout:hover { color: #fff; border-color: var(--accent); background: rgba(255, 0, 0, .12); }

        /* ---------- Layout ---------- */
        .shell { padding-top: 64px; padding-bottom: 96px; }

        .sidebar {
            position: fixed;
            top: 64px; bottom: 96px; left: 0;
            width: 240px;
            padding: 14px 12px;
            overflow-y: auto;
            border-right: 1px solid #131313;
        }
        .nav-item {
            display: flex;
            align-items: center;
            gap: 18px;
            padding: 11px 15px;
            margin-bottom: 2px;
            border-radius: 9px;
            color: #d3d3d3;
            font-size: 14px;
            transition: background .15s, color .15s;
        }
        .nav-item:hover { background: #1b1b1b; color: #fff; }
        .nav-item.active { background: var(--surface); color: #fff; font-weight: 600; }
        .nav-item.active svg { color: var(--accent); }

        .nav-sep { height: 1px; background: #1f1f1f; margin: 14px 12px; }
        .nav-title {
            font-size: 11px;
            font-weight: 700;
            letter-spacing: 1.4px;
            text-transform: uppercase;
            color: var(--muted-2);
            padding: 0 15px 10px;
        }

        .content {
            margin-left: 240px;
            padding: 26px 34px 40px;
            max-width: 1680px;
        }

        /* ---------- Greeting / chips ---------- */
        .greeting {
            font-size: 30px;
            font-weight: 800;
            letter-spacing: -.7px;
            margin: 2px 0 18px;
        }
        .greeting .hl { color: #ff5c5c; }

        .chips { display: flex; flex-wrap: wrap; gap: 10px; margin-bottom: 26px; }
        .chip {
            font-size: 13px;
            padding: 8px 15px;
            border-radius: 18px;
            background: #1e1e1e;
            color: #eaeaea;
            border: 1px solid #2c2c2c;
        }
        .chip.on { background: #fff; color: #030303; font-weight: 700; border-color: #fff; }

        /* ---------- Hero ---------- */
        .hero {
            display: flex;
            align-items: center;
            gap: 26px;
            padding: 22px;
            margin-bottom: 38px;
            border-radius: 16px;
            border: 1px solid #2b2b2b;
            background: linear-gradient(100deg, #3d0d0d 0%, #1d0a0a 42%, #0e0e0e 100%);
        }
        .hero-cover {
            flex: 0 0 auto;
            width: 154px; height: 154px;
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            background: linear-gradient(140deg, #ff4b2b 0%, #8e1010 55%, #1a1a1a 100%);
            box-shadow: 0 16px 34px rgba(0, 0, 0, .6);
        }
        .hero-body { min-width: 0; }
        .hero-label {
            font-size: 11px;
            font-weight: 800;
            letter-spacing: 2.2px;
            text-transform: uppercase;
            color: #ff9b9b;
        }
        .hero-title {
            font-size: 32px;
            font-weight: 800;
            letter-spacing: -.8px;
            margin: 9px 0 6px;
            line-height: 1.15;
        }
        .hero-sub { color: #c2c2c2; font-size: 14px; }
        .hero-play {
            display: inline-flex;
            align-items: center;
            gap: 9px;
            margin-top: 18px;
            padding: 12px 26px;
            border-radius: 24px;
            background: var(--accent);
            color: #fff;
            font-size: 14px;
            font-weight: 700;
            transition: background .15s, transform .15s;
        }
        .hero-play:hover { background: #ff2b2b; transform: translateY(-1px); }

        /* ---------- Section head ---------- */
        .section-head {
            display: flex;
            align-items: baseline;
            justify-content: space-between;
            margin-bottom: 18px;
        }
        .section-title { font-size: 21px; font-weight: 800; letter-spacing: -.4px; }
        .section-count { font-size: 12px; color: #8c8c8c; }

        /* ---------- Cards ---------- */
        .cards {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(178px, 1fr));
            gap: 26px 18px;
        }

        .card-cover {
            position: relative;
            display: block;
            width: 100%;
            padding-top: 100%;
            border-radius: 9px;
            overflow: hidden;
        }
        .card-cover::after {
            content: "";
            position: absolute;
            top: 0; right: 0; bottom: 0; left: 0;
            background: linear-gradient(180deg, rgba(0, 0, 0, 0) 45%, rgba(0, 0, 0, .38) 100%);
            pointer-events: none;
        }
        .card-cover .note {
            position: absolute;
            top: 0; right: 0; bottom: 0; left: 0;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .card-cover .fab {
            position: absolute;
            right: 10px; bottom: 10px;
            width: 42px; height: 42px;
            border-radius: 50%;
            background: #fff;
            display: flex;
            align-items: center;
            justify-content: center;
            opacity: 0;
            transform: translateY(8px);
            transition: opacity .18s, transform .18s;
            box-shadow: 0 8px 20px rgba(0, 0, 0, .55);
            z-index: 2;
        }
        .card-cover:hover .fab { opacity: 1; transform: translateY(0); }

        .card-title {
            margin-top: 11px;
            font-size: 14px;
            font-weight: 600;
            color: #fff;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .card-sub {
            margin-top: 3px;
            font-size: 12px;
            color: #a3a3a3;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .card-meta { margin-top: 6px; font-size: 11px; color: var(--muted-2); }
        .card.playing .card-title { color: #ff5c5c; }
        .card.playing .card-meta { color: #ff8a8a; }

        /* ---------- Empty ---------- */
        .empty {
            border: 1px dashed #2e2e2e;
            border-radius: 14px;
            padding: 54px 20px;
            text-align: center;
            color: #8c8c8c;
        }
        .empty strong { display: block; color: #e6e6e6; font-size: 16px; margin-bottom: 6px; }

        /* ---------- Player bar ---------- */
        .playerbar {
            position: fixed;
            left: 0; right: 0; bottom: 0;
            height: 92px;
            z-index: 60;
            display: grid;
            grid-template-columns: minmax(180px, 1fr) minmax(280px, 1.6fr) minmax(120px, 1fr);
            align-items: center;
            gap: 22px;
            padding: 0 22px;
            background: var(--surface-2);
            border-top: 1px solid #282828;
        }

        .pb-left { display: flex; align-items: center; gap: 13px; min-width: 0; }
        .pb-cover {
            flex: 0 0 auto;
            width: 54px; height: 54px;
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            background: linear-gradient(140deg, #ff4b2b 0%, #7d0f0f 60%, #1c1c1c 100%);
        }
        .pb-info { min-width: 0; }
        .pb-title {
            font-size: 13px;
            font-weight: 600;
            color: #fff;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }
        .pb-artist {
            margin-top: 3px;
            font-size: 11px;
            color: #9d9d9d;
            overflow: hidden;
            text-overflow: ellipsis;
            white-space: nowrap;
        }

        .pb-center { display: flex; flex-direction: column; align-items: center; gap: 4px; }
        .pb-controls { display: flex; align-items: center; gap: 14px; }
        .pb-btn {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            width: 34px; height: 34px;
            border: 0;
            border-radius: 50%;
            background: transparent;
            color: #dedede;
            cursor: pointer;
            transition: background .15s, color .15s;
        }
        .pb-btn:hover { background: #2a2a2a; color: #fff; }
        .pb-play {
            width: 44px; height: 44px;
            background: #fff;
            color: #000;
        }
        .pb-play:hover { background: #fff; color: #000; transform: scale(1.06); }
        .pb-play:disabled { opacity: .45; cursor: default; transform: none; }

        .pb-progress { display: flex; align-items: center; gap: 10px; width: 100%; max-width: 560px; }
        .pb-time { font-size: 11px; color: #9a9a9a; min-width: 34px; text-align: center; font-variant-numeric: tabular-nums; }

        input[type="range"] {
            -webkit-appearance: none;
            appearance: none;
            width: 100%;
            height: 4px;
            border-radius: 2px;
            background: #3a3a3a;
            outline: none;
            cursor: pointer;
            margin: 0;
        }
        input[type="range"]::-webkit-slider-thumb {
            -webkit-appearance: none;
            appearance: none;
            width: 12px; height: 12px;
            border-radius: 50%;
            background: var(--accent);
            border: 0;
        }
        input[type="range"]::-moz-range-thumb {
            width: 12px; height: 12px;
            border: 0;
            border-radius: 50%;
            background: var(--accent);
        }

        .pb-right { display: flex; align-items: center; justify-content: flex-end; gap: 10px; color: #9a9a9a; }
        .pb-right input[type="range"] { max-width: 110px; }

        /* ---------- Toast ---------- */
        .toast {
            position: fixed;
            left: 50%;
            bottom: 108px;
            transform: translateX(-50%) translateY(12px);
            padding: 12px 20px;
            border-radius: 10px;
            background: #2b2b2b;
            border: 1px solid #3d3d3d;
            color: #f0f0f0;
            font-size: 13px;
            opacity: 0;
            pointer-events: none;
            transition: opacity .2s, transform .2s;
            z-index: 80;
        }
        .toast.show { opacity: 1; transform: translateX(-50%) translateY(0); }

        /* ---------- Responsive ---------- */
        @media (max-width: 1000px) {
            .sidebar { display: none; }
            .content { margin-left: 0; padding: 18px; }
            .user-name { display: none; }
            .hero-cover { width: 110px; height: 110px; }
            .hero-title { font-size: 24px; }
            .playerbar {
                grid-template-columns: minmax(110px, 1fr) minmax(200px, 1.5fr);
                height: 86px;
            }
            .pb-right { display: none; }
            .pb-progress { max-width: 320px; }
        }

        @media (max-width: 620px) {
            .brand .name { display: none; }
            .topbar { gap: 12px; padding: 0 12px; }
            .search-box { padding-left: 14px; }
            .search-btn { padding: 0 12px; }
            .logout { padding: 8px 11px; }
            .logout-text { display: none; }
            .greeting { font-size: 22px; }
            .hero { flex-direction: column; align-items: flex-start; gap: 16px; }
            .cards { grid-template-columns: repeat(auto-fill, minmax(140px, 1fr)); }
            .playerbar { grid-template-columns: 1fr auto; }
            .pb-progress { display: none; }
        }
    </style>
</head>
<body>
    <form id="formSong" runat="server">

        <!-- ================= TOP BAR ================= -->
        <header class="topbar">
            <div class="brand">
                <span class="logo">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="#ffffff"><path d="M8 5v14l11-7z" /></svg>
                </span>
                <span class="name">PoliMusic</span>
            </div>

            <div class="search-wrap">
                <div class="search-box">
                    <asp:TextBox ID="txtSearch" runat="server" placeholder="Busca canciones o artistas"></asp:TextBox>
                    <asp:Button ID="btnSearch" runat="server" CssClass="search-btn" Text="Buscar" OnClick="BtnSearch_Click" />
                </div>
            </div>

            <div class="user-area">
                <div class="user-chip">
                    <asp:Image ID="imgUserPhoto" runat="server" CssClass="avatar" AlternateText="Foto de usuario" />
                    <asp:Label ID="lblUserName" runat="server" CssClass="user-name"></asp:Label>
                    <asp:Label ID="lblUserType" runat="server" CssClass="badge" Visible="false"></asp:Label>
                </div>
                <asp:LinkButton ID="btnLogout" runat="server" CssClass="logout" OnClick="BtnLogout_Click" CausesValidation="false">
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor"><path d="M10 3H5v18h5v-2H7V5h3V3zm4.6 4.4-1.4 1.4L16.2 12H9v2h7.2l-3 3.2 1.4 1.4L20 12l-5.4-4.6z" /></svg>
                    <span class="logout-text">Cerrar sesión</span>
                </asp:LinkButton>
            </div>
        </header>

        <!-- ================= SHELL ================= -->
        <div class="shell">

            <aside class="sidebar">
                <a class="nav-item active" href="Song.aspx">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor"><path d="M12 3 2 11h3v10h6v-6h2v6h6V11h3L12 3z" /></svg>
                    Inicio
                </a>
                <a class="nav-item" href="Song.aspx">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor"><path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20zm3.6 6.4-2 5.2-5.2 2 2-5.2 5.2-2z" /></svg>
                    Explorar
                </a>
                <a class="nav-item" href="Song.aspx">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor"><path d="M4 3h2v18H4zM8 3h2v18H8zM13 4l7 17-1.9.8L11.1 4.8 13 4z" /></svg>
                    Biblioteca
                </a>

                <div class="nav-sep"></div>
                <div class="nav-title">Mi música</div>

                <a class="nav-item" href="Song.aspx">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor"><path d="M12 21s-8-5.1-8-10.4A4.6 4.6 0 0 1 12 7a4.6 4.6 0 0 1 8 3.6C20 15.9 12 21 12 21z" /></svg>
                    Me gusta
                </a>
                <a class="nav-item" href="Song.aspx">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor"><path d="M12 3v10.6a3.4 3.4 0 1 0 2 3.1V7h6V3h-8z" /></svg>
                    Mis canciones
                </a>
            </aside>

            <main class="content">

                <h1 class="greeting">
                    <asp:Label ID="lblGreeting" runat="server"></asp:Label>
                </h1>

                <div class="chips">
                    <span class="chip on">Todo</span>
                    <span class="chip">Música</span>
                    <span class="chip">Álbumes</span>
                    <span class="chip">Artistas</span>
                </div>

                <asp:Panel ID="pnlHero" runat="server" CssClass="hero">
                    <div class="hero-cover">
                        <svg width="58" height="58" viewBox="0 0 24 24" fill="rgba(255,255,255,.85)"><path d="M12 3v10.6a3.4 3.4 0 1 0 2 3.1V7h6V3h-8z" /></svg>
                    </div>
                    <div class="hero-body">
                        <div class="hero-label">Lo más escuchado</div>
                        <div class="hero-title">
                            <asp:Label ID="lblHeroTitle" runat="server"></asp:Label>
                        </div>
                        <div class="hero-sub">
                            <asp:Label ID="lblHeroArtist" runat="server"></asp:Label>
                            &nbsp;&middot;&nbsp;
                            <asp:Label ID="lblHeroPlays" runat="server"></asp:Label>
                        </div>
                        <asp:HyperLink ID="lnkHeroPlay" runat="server" CssClass="hero-play">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="#ffffff"><path d="M8 5v14l11-7z" /></svg>
                            Reproducir
                        </asp:HyperLink>
                    </div>
                </asp:Panel>

                <div class="section-head">
                    <span class="section-title">Canciones</span>
                    <asp:Label ID="lblSongCount" runat="server" CssClass="section-count"></asp:Label>
                </div>

                <asp:Repeater ID="rptSongs" runat="server">
                    <HeaderTemplate>
                        <div class="cards">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="card">
                            <a class="card-cover"
                               href='Song.aspx?play=<%# Eval("ID_SONG") %>'
                               data-id='<%# Eval("ID_SONG") %>'
                               data-path='<%# NormalizeSongPath(Eval("SONG_PATH")) %>'
                               data-title='<%# HttpUtility.HtmlAttributeEncode(Eval("SONG_NAME").ToString()) %>'
                               data-artist='<%# HttpUtility.HtmlAttributeEncode(GetArtistName(Eval("ARTIST_NAME"))) %>'
                               style='<%# GetCoverStyle(Container.ItemIndex) %>'>
                                <span class="note">
                                    <svg width="54" height="54" viewBox="0 0 24 24" fill="rgba(255,255,255,.6)"><path d="M12 3v10.6a3.4 3.4 0 1 0 2 3.1V7h6V3h-8z" /></svg>
                                </span>
                                <span class="fab">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="#000000"><path d="M8 5v14l11-7z" /></svg>
                                </span>
                            </a>
                            <div class="card-title"><%# Eval("SONG_NAME") %></div>
                            <div class="card-sub"><%# GetArtistName(Eval("ARTIST_NAME")) %></div>
                            <div class="card-meta"><%# Eval("PLAYS") %> reproducciones</div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        </div>
                    </FooterTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlEmpty" runat="server" CssClass="empty" Visible="false">
                    <strong>Sin resultados</strong>
                    No encontramos canciones con ese nombre. Prueba con otra búsqueda.
                </asp:Panel>

            </main>
        </div>

        <!-- ================= PLAYER ================= -->
        <div class="playerbar">
            <div class="pb-left">
                <div class="pb-cover">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="rgba(255,255,255,.9)"><path d="M12 3v10.6a3.4 3.4 0 1 0 2 3.1V7h6V3h-8z" /></svg>
                </div>
                <div class="pb-info">
                    <div class="pb-title">
                        <asp:Label ID="lblPlayerTitle" runat="server" Text="Selecciona una canción"></asp:Label>
                    </div>
                    <div class="pb-artist">
                        <asp:Label ID="lblPlayerArtist" runat="server" Text="PoliMusic"></asp:Label>
                    </div>
                </div>
            </div>

            <div class="pb-center">
                <div class="pb-controls">
                    <button type="button" class="pb-btn" id="btnPrev" title="Anterior">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M6 5h2v14H6zM20 5v14L9 12z" /></svg>
                    </button>
                    <button type="button" class="pb-btn pb-play" id="btnPlay" title="Reproducir">
                        <svg id="iconPlay" width="20" height="20" viewBox="0 0 24 24" fill="currentColor"><path d="M8 5v14l11-7z" /></svg>
                        <svg id="iconPause" width="20" height="20" viewBox="0 0 24 24" fill="currentColor" style="display:none"><path d="M6 5h4v14H6zM14 5h4v14h-4z" /></svg>
                    </button>
                    <button type="button" class="pb-btn" id="btnNext" title="Siguiente">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M18 5h2v14h-2zM4 5l11 7-11 7z" /></svg>
                    </button>
                </div>
                <div class="pb-progress">
                    <span class="pb-time" id="curTime">0:00</span>
                    <input type="range" id="seek" min="0" max="100" value="0" step="0.1" />
                    <span class="pb-time" id="durTime">0:00</span>
                </div>
            </div>

            <div class="pb-right">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor"><path d="M4 9v6h4l5 4V5L8 9H4zm12.5 3a4.5 4.5 0 0 0-2.5-4v8a4.5 4.5 0 0 0 2.5-4z" /></svg>
                <input type="range" id="volume" min="0" max="1" step="0.01" value="0.85" />
            </div>
        </div>

        <audio id="audioPlayer" preload="metadata"></audio>

        <asp:HiddenField ID="hdnSongId" runat="server" />
        <asp:HiddenField ID="hdnSongPath" runat="server" />
        <asp:HiddenField ID="hdnAutoplay" runat="server" Value="0" EnableViewState="false" />

        <div class="toast" id="toast"></div>
        <script type="text/javascript">
            (function () {
                var audio = document.getElementById('audioPlayer');
                var seek = document.getElementById('seek');
                var volume = document.getElementById('volume');
                var curTime = document.getElementById('curTime');
                var durTime = document.getElementById('durTime');
                var iconPlay = document.getElementById('iconPlay');
                var iconPause = document.getElementById('iconPause');
                var btnPlay = document.getElementById('btnPlay');
                var toast = document.getElementById('toast');
                var lblPlayerTitle = document.getElementById('<%= lblPlayerTitle.ClientID %>');
                var lblPlayerArtist = document.getElementById('<%= lblPlayerArtist.ClientID %>');

                var hdnSongId = document.getElementById('<%= hdnSongId.ClientID %>');
                var hdnSongPath = document.getElementById('<%= hdnSongPath.ClientID %>');
                var hdnAutoplay = document.getElementById('<%= hdnAutoplay.ClientID %>');

                var toastTimer = null;

                function showToast(message) {
                    toast.innerHTML = message;
                    toast.className = 'toast show';
                    if (toastTimer) { clearTimeout(toastTimer); }
                    toastTimer = setTimeout(function () { toast.className = 'toast'; }, 3600);
                }

                function formatTime(seconds) {
                    if (!isFinite(seconds) || seconds < 0) { return '0:00'; }
                    var total = Math.floor(seconds);
                    var minutes = Math.floor(total / 60);
                    var rest = total % 60;
                    return minutes + ':' + (rest < 10 ? '0' : '') + rest;
                }

                function paintRange(element, percentage) {
                    var value = Math.max(0, Math.min(100, percentage));
                    element.style.background = 'linear-gradient(to right, #ff0000 0%, #ff0000 ' + value + '%, #3a3a3a ' + value + '%, #3a3a3a 100%)';
                }

                function setPlayingState(isPlaying) {
                    iconPlay.style.display = isPlaying ? 'none' : 'block';
                    iconPause.style.display = isPlaying ? 'block' : 'none';
                    btnPlay.title = isPlaying ? 'Pausar' : 'Reproducir';
                }

                /* ---------- Cards of the current list (for prev/next) ---------- */
                function getCards() {
                    var nodes = document.querySelectorAll('.card-cover');
                    var cards = [];
                    for (var i = 0; i < nodes.length; i++) {
                        cards.push(nodes[i]);
                    }
                    return cards;
                }

                function highlightCurrent() {
                    var cards = getCards();
                    for (var i = 0; i < cards.length; i++) {
                        var card = cards[i].parentNode;
                        if (card) {
                            if (cards[i].getAttribute('data-id') === hdnSongId.value) {
                                card.className = 'card playing';
                            } else {
                                card.className = 'card';
                            }
                        }
                    }
                }

                function playSongFromData(id, path, title, artist) {
                    if (!path) {
                        showToast('No se encontró la ruta del archivo de audio.');
                        return;
                    }
                    hdnSongId.value = id;
                    hdnSongPath.value = path;
                    if (lblPlayerTitle && title) { lblPlayerTitle.innerText = title; }
                    if (lblPlayerArtist && artist) { lblPlayerArtist.innerText = artist; }

                    audio.src = path;
                    btnPlay.disabled = false;
                    highlightCurrent();

                    var attempt = audio.play();
                    if (attempt && typeof attempt.catch === 'function') {
                        attempt.catch(function (err) {
                            console.error('Audio playback error:', err);
                            showToast('No se pudo reproducir el archivo de audio. Verifica que el MP3 exista en SongFiles.');
                            setPlayingState(false);
                        });
                    }

                    // Register play count asynchronously
                    try {
                        var xhr = new XMLHttpRequest();
                        xhr.open('POST', 'Song.aspx/RegisterPlay', true);
                        xhr.setRequestHeader('Content-Type', 'application/json; charset=utf-8');
                        xhr.send(JSON.stringify({ idSong: parseInt(id, 10) }));
                    } catch (e) { }
                }

                function goToCard(card) {
                    if (!card) { return; }
                    var id = card.getAttribute('data-id');
                    var path = card.getAttribute('data-path');
                    var title = card.getAttribute('data-title');
                    var artist = card.getAttribute('data-artist');
                    if (id && path) {
                        playSongFromData(id, path, title, artist);
                    } else {
                        window.location.href = 'Song.aspx?play=' + id;
                    }
                }

                function moveInList(offset) {
                    var cards = getCards();
                    if (cards.length === 0) { return; }
                    var currentId = hdnSongId.value;
                    var index = -1;
                    for (var i = 0; i < cards.length; i++) {
                        if (cards[i].getAttribute('data-id') === currentId) { index = i; break; }
                    }
                    if (index === -1) { goToCard(cards[0]); return; }
                    var next = index + offset;
                    if (next < 0) { next = cards.length - 1; }
                    if (next >= cards.length) { next = 0; }
                    goToCard(cards[next]);
                }

                /* ---------- Click events on cards and hero play button ---------- */
                document.addEventListener('click', function (e) {
                    var target = e.target;
                    var heroBtn = target.closest('#<%= lnkHeroPlay.ClientID %>');
                    if (heroBtn) {
                        e.preventDefault();
                        var id = heroBtn.getAttribute('data-id');
                        var path = heroBtn.getAttribute('data-path');
                        var title = heroBtn.getAttribute('data-title');
                        var artist = heroBtn.getAttribute('data-artist');
                        if (id && path) {
                            playSongFromData(id, path, title, artist);
                            return;
                        }
                    }

                    var cardCover = target.closest('.card-cover');
                    if (cardCover) {
                        e.preventDefault();
                        var id = cardCover.getAttribute('data-id');
                        var path = cardCover.getAttribute('data-path');
                        var title = cardCover.getAttribute('data-title');
                        var artist = cardCover.getAttribute('data-artist');
                        if (id && path) {
                            playSongFromData(id, path, title, artist);
                        }
                    }
                });

                /* ---------- Audio wiring ---------- */
                var songPath = hdnSongPath.value;
                if (songPath && songPath !== '') {
                    audio.src = songPath;
                    highlightCurrent();
                    btnPlay.disabled = false;
                    if (hdnAutoplay.value === '1') {
                        var attempt = audio.play();
                        if (attempt && typeof attempt.catch === 'function') {
                            attempt.catch(function () {
                                setPlayingState(false);
                            });
                        }
                    }
                } else {
                    var allCards = getCards();
                    if (allCards.length > 0) {
                        btnPlay.disabled = false;
                    } else {
                        btnPlay.disabled = true;
                    }
                }

                audio.addEventListener('play', function () { setPlayingState(true); });
                audio.addEventListener('pause', function () { setPlayingState(false); });

                audio.addEventListener('loadedmetadata', function () {
                    durTime.innerHTML = formatTime(audio.duration);
                });

                audio.addEventListener('timeupdate', function () {
                    curTime.innerHTML = formatTime(audio.currentTime);
                    if (audio.duration > 0) {
                        var percentage = (audio.currentTime / audio.duration) * 100;
                        seek.value = percentage;
                        paintRange(seek, percentage);
                    }
                });

                audio.addEventListener('ended', function () { moveInList(1); });

                audio.addEventListener('error', function () {
                    if (audio.src) {
                        showToast('No se pudo reproducir el archivo de audio. Verifica que el archivo exista en SongFiles.');
                        setPlayingState(false);
                    }
                });

                btnPlay.addEventListener('click', function () {
                    if (!audio.src || audio.src === '' || audio.src === window.location.href) {
                        var cards = getCards();
                        if (cards.length > 0) {
                            goToCard(cards[0]);
                            return;
                        }
                        showToast('Selecciona una canción de la lista.');
                        return;
                    }
                    if (audio.paused) {
                        var p = audio.play();
                        if (p && typeof p.catch === 'function') {
                            p.catch(function (err) {
                                console.error('Play error:', err);
                                showToast('No se pudo reproducir el audio.');
                            });
                        }
                    } else {
                        audio.pause();
                    }
                });

                document.getElementById('btnPrev').addEventListener('click', function () { moveInList(-1); });
                document.getElementById('btnNext').addEventListener('click', function () { moveInList(1); });

                seek.addEventListener('input', function () {
                    if (audio.duration > 0) {
                        audio.currentTime = (seek.value / 100) * audio.duration;
                        paintRange(seek, seek.value);
                    }
                });

                volume.addEventListener('input', function () {
                    audio.volume = volume.value;
                    paintRange(volume, volume.value * 100);
                });

                audio.volume = volume.value;
                paintRange(volume, volume.value * 100);
                paintRange(seek, 0);
            })();
        </script>

    </form>
</body>
</html>
