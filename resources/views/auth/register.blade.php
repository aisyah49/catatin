<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="theme-color" content="#3B82F6">
<title>Daftar — Catatin</title>
<style>
:root{--bg:#F8FAFC;--white:#fff;--blue:#3B82F6;--blue-d:#1E3A8A;--ink:#1E293B;--muted:#64748B;--line:#E2E8F0;--danger:#DC2626;color-scheme:light;}
@media (prefers-color-scheme: dark){:root{--bg:#0F172A;--white:#1E293B;--blue:#60A5FA;--blue-d:#93C5FD;--ink:#E2E8F0;--muted:#94A3B8;--line:#334155;color-scheme:dark;}}
*{box-sizing:border-box;}
body{margin:0;min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px;background:var(--bg);color:var(--ink);font-family:system-ui,-apple-system,'Segoe UI',Roboto,sans-serif;}
.card{width:100%;max-width:380px;background:var(--white);border:1px solid var(--line);border-radius:16px;padding:28px 24px;box-shadow:0 10px 30px rgba(15,23,42,.08);}
.logo{font-size:2rem;text-align:center;margin-bottom:4px;}
h1{margin:0 0 4px;text-align:center;font-size:1.35rem;color:var(--blue-d);}
p.sub{margin:0 0 20px;text-align:center;color:var(--muted);font-size:.9rem;}
label{display:block;font-size:.82rem;font-weight:600;margin:14px 0 6px;}
input[type=email],input[type=password],input[type=text]{width:100%;padding:11px 12px;font-size:1rem;border:1px solid var(--line);border-radius:10px;background:var(--bg);color:var(--ink);}
input:focus{outline:2px solid var(--blue);outline-offset:1px;}
.pw{position:relative;}
.pw button{position:absolute;right:6px;top:50%;transform:translateY(-50%);border:0;background:none;color:var(--muted);cursor:pointer;padding:6px 8px;font-size:.8rem;}
.remember{display:flex;align-items:center;gap:8px;margin:14px 0 4px;font-size:.88rem;color:var(--muted);}
.btn{width:100%;margin-top:18px;padding:12px;border:0;border-radius:10px;background:var(--blue);color:#fff;font-size:1rem;font-weight:700;cursor:pointer;}
.btn:disabled{opacity:.6;cursor:wait;}
.alt{margin:16px 0 0;text-align:center;font-size:.88rem;color:var(--muted);}.alt a{color:var(--blue);font-weight:600;text-decoration:none;}
.err{margin-bottom:6px;padding:10px 12px;border-radius:10px;background:rgba(220,38,38,.1);color:var(--danger);font-size:.88rem;}
</style>
</head>
<body>
<form class="card" method="POST" action="/register" id="f">
  @csrf
  <div class="logo">📒</div>
  <h1>Buat Akun</h1>
  <p class="sub">Akun baru mulai dengan catatan kosong</p>

  @if ($errors->any())
    <div class="err">{{ $errors->first() }}</div>
  @endif

  <label for="name">Nama</label>
  <input id="name" name="name" type="text" value="{{ old('name') }}" autocomplete="name" required autofocus>

  <label for="email">Email</label>
  <input id="email" name="email" type="email" value="{{ old('email') }}" autocomplete="username" required>

  <label for="password">Password (min. 6 karakter)</label>
  <input id="password" name="password" type="password" autocomplete="new-password" minlength="6" required>

  <label for="password_confirmation">Ulangi password</label>
  <input id="password_confirmation" name="password_confirmation" type="password" autocomplete="new-password" required>

  <button class="btn" id="go" type="submit">Daftar</button>
  <p class="alt">Sudah punya akun? <a href="/login">Masuk</a></p>
</form>
<script>
document.getElementById('f').addEventListener('submit', function(){ var b = document.getElementById('go'); b.disabled = true; b.textContent = 'Memproses…'; });
</script>
</body>
</html>
