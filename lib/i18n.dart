import 'package:flutter/material.dart' as m;

/// Çok dilli arayüz: Türkçe (varsayılan), İngilizce, Almanca, Fransızca.
/// Anahtarlar Türkçe metindir; çeviri bulunamazsa Türkçe gösterilir.
class L {
  static String lang = 'tr';
  static const langs = {'tr': 'Türkçe', 'en': 'English', 'de': 'Deutsch', 'fr': 'Français'};
  static const codes = ['tr', 'en', 'de', 'fr'];
}

String tr(String s) {
  if (L.lang == 'tr') return s;
  final e = _t[s];
  if (e == null) return s;
  final i = const {'en': 0, 'de': 1, 'fr': 2}[L.lang];
  return i == null ? s : e[i];
}

/// {ad} yer tutuculu çeviri.
String trf(String s, Map<String, Object?> args) {
  var r = tr(s);
  args.forEach((k, v) => r = r.replaceAll('{$k}', '$v'));
  return r;
}

/// Flutter'ın Text'inin yerine geçer: metni seçili dile otomatik çevirir.
class Text extends m.StatelessWidget {
  const Text(this.data,
      {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap});
  final String data;
  final m.TextStyle? style;
  final m.TextAlign? textAlign;
  final int? maxLines;
  final m.TextOverflow? overflow;
  final bool? softWrap;

  @override
  m.Widget build(m.BuildContext context) => m.Text(tr(data),
      style: style, textAlign: textAlign, maxLines: maxLines, overflow: overflow, softWrap: softWrap);
}

const Map<String, List<String>> _t = {
  'Yeni ayarlar şifresi': ['New settings password', 'Neues Einstellungspasswort', 'Nouveau mot de passe des paramètres'],
  'Ayarlar şifresi': ['Settings password', 'Einstellungspasswort', 'Mot de passe des paramètres'],
  'Şifre en az 4 haneli olmalı.': ['Password must be at least 4 digits.', 'Das Passwort muss mindestens 4 Ziffern haben.', 'Le mot de passe doit comporter au moins 4 chiffres.'],
  'Şifreler eşleşmiyor.': ['Passwords do not match.', 'Die Passwörter stimmen nicht überein.', 'Les mots de passe ne correspondent pas.'],
  'Yanlış şifre.': ['Wrong password.', 'Falsches Passwort.', 'Mot de passe incorrect.'],
  'Yeni şifre (en az 4 hane)': ['New password (min. 4 digits)', 'Neues Passwort (mind. 4 Ziffern)', 'Nouveau mot de passe (4 chiffres min.)'],
  'Şifre (tekrar)': ['Password (repeat)', 'Passwort (wiederholen)', 'Mot de passe (répéter)'],
  'Güvenlik': ['Security', 'Sicherheit', 'Sécurité'],
  'Ayarlar şifresini değiştir': ['Change settings password', 'Einstellungspasswort ändern', 'Changer le mot de passe des paramètres'],
  'Varsayılan şifre 0000. Değiştirmeni öneririz.': ['Default password is 0000. We recommend changing it.', 'Standardpasswort ist 0000. Wir empfehlen, es zu ändern.', 'Le mot de passe par défaut est 0000. Nous te conseillons de le changer.'],
  'Ayarlar kilitli': ['Settings are locked', 'Einstellungen sind gesperrt', 'Les paramètres sont verrouillés'],
  'Şifreyi gir': ['Enter password', 'Passwort eingeben', 'Saisir le mot de passe'],
  '{n} dk\'da kaldı': ['left off at {n} min', 'bei {n} Min. aufgehört', 'arrêté à {n} min'],
  'Canlı TV': ['Live TV', 'Live-TV', 'TV en direct'],
  'Filmler': ['Movies', 'Filme', 'Films'],
  'Diziler': ['Series', 'Serien', 'Séries'],
  'Favoriler': ['Favorites', 'Favoriten', 'Favoris'],
  'Geçmiş': ['History', 'Verlauf', 'Historique'],
  'Abonelikler': ['Subscriptions', 'Abos', 'Abonnements'],
  'Ayarlar': ['Settings', 'Einstellungen', 'Paramètres'],
  'Canlı': ['Live', 'Live', 'En direct'],
  'Film': ['Movie', 'Film', 'Film'],
  'Dizi': ['Series', 'Serie', 'Série'],
  'Abonelik silinsin mi?': ['Delete subscription?', 'Abo löschen?', 'Supprimer l\'abonnement ?'],
  '"{name}" listeden kaldırılacak. Bu aboneliğin favorileri ve geçmişi de silinir.': ['"{name}" will be removed from the list. Its favorites and history will also be deleted.', '„{name}“ wird aus der Liste entfernt. Favoriten und Verlauf dieses Abos werden ebenfalls gelöscht.', '« {name} » sera retiré de la liste. Ses favoris et son historique seront aussi supprimés.'],
  'Vazgeç': ['Cancel', 'Abbrechen', 'Annuler'],
  'Sil': ['Delete', 'Löschen', 'Supprimer'],
  'IPTV abonelikleri': ['IPTV subscriptions', 'IPTV-Abos', 'Abonnements IPTV'],
  'Kullanmak istediğin sağlayıcıya tıkla, uygulama o aboneliğe geçer.': ['Tap the provider you want to use and the app switches to that subscription.', 'Tippe auf den gewünschten Anbieter, die App wechselt zu diesem Abo.', 'Touche le fournisseur souhaité, l’application passe à cet abonnement.'],
  'Kullanımda': ['In use', 'In Benutzung', 'Utilisé'],
  'Yeni abonelik ekle': ['Add new subscription', 'Neues Abo hinzufügen', 'Ajouter un abonnement'],
  '{name} aboneliğine geçildi': ['Switched to {name}', 'Zu {name} gewechselt', 'Passé à {name}'],
  'Liste yükleniyor…': ['Loading list…', 'Liste wird geladen…', 'Chargement de la liste…'],
  'Tekrar dene': ['Try again', 'Erneut versuchen', 'Réessayer'],
  'Tümü': ['All', 'Alle', 'Tout'],
  'Sırala': ['Sort', 'Sortieren', 'Trier'],
  'Sunucu sırası': ['Server order', 'Serverreihenfolge', 'Ordre du serveur'],
  'En yeni eklenen': ['Newest first', 'Neueste zuerst', 'Plus récents'],
  'Özel sıralama (sürükle)': ['Custom order (drag)', 'Eigene Reihenfolge (ziehen)', 'Ordre personnalisé (glisser)'],
  'Listeyi yenile': ['Refresh list', 'Liste aktualisieren', 'Actualiser la liste'],
  'Yetişkin içeriği kilitle': ['Lock adult content', 'Erwachseneninhalte sperren', 'Verrouiller le contenu adulte'],
  'Yetişkin içeriği aç': ['Unlock adult content', 'Erwachseneninhalte entsperren', 'Déverrouiller le contenu adulte'],
  'Sonuç yok': ['No results', 'Keine Ergebnisse', 'Aucun résultat'],
  'Canlı ara…': ['Search live TV…', 'Live-TV suchen…', 'Rechercher en direct…'],
  'Film ara…': ['Search movies…', 'Filme suchen…', 'Rechercher un film…'],
  'Dizi ara…': ['Search series…', 'Serien suchen…', 'Rechercher une série…'],
  'Henüz favori {t} yok.\nTamam tuşunu 3 sn basılı tutarak (veya uzun basarak) ekleyebilirsin.': ['No favorite {t} yet.\nHold the OK button for 3 seconds (or long-press) to add one.', 'Noch keine Favoriten ({t}).\nHalte die OK-Taste 3 Sekunden gedrückt (oder lange drücken), um einen hinzuzufügen.', 'Aucun favori ({t}) pour l’instant.\nMaintiens la touche OK 3 secondes (ou appui long) pour en ajouter.'],
  'şimdi': ['just now', 'gerade eben', 'à l’instant'],
  '{n} dk önce': ['{n} min ago', 'vor {n} Min.', 'il y a {n} min'],
  '{n} sa önce': ['{n} h ago', 'vor {n} Std.', 'il y a {n} h'],
  '{n} gün önce': ['{n} days ago', 'vor {n} Tagen', 'il y a {n} j'],
  '{n} ay önce': ['{n} months ago', 'vor {n} Monaten', 'il y a {n} mois'],
  'Geçmişi temizle': ['Clear history', 'Verlauf löschen', 'Effacer l’historique'],
  'Geçmiş temizlensin mi?': ['Clear history?', 'Verlauf löschen?', 'Effacer l’historique ?'],
  'Temizle': ['Clear', 'Leeren', 'Effacer'],
  'İzleme geçmişi boş.': ['Watch history is empty.', 'Der Verlauf ist leer.', 'L’historique est vide.'],
  'Sunucu, kullanıcı adı ve şifre gerekli.': ['Server, username and password are required.', 'Server, Benutzername und Passwort sind erforderlich.', 'Serveur, nom d’utilisateur et mot de passe requis.'],
  'Hesaplar': ['Accounts', 'Konten', 'Comptes'],
  'Kayıtlı hesaplar': ['Saved accounts', 'Gespeicherte Konten', 'Comptes enregistrés'],
  'Kullanıcı ekle (Xtream Codes)': ['Add user (Xtream Codes)', 'Benutzer hinzufügen (Xtream Codes)', 'Ajouter un utilisateur (Xtream Codes)'],
  'Hesap adı (isteğe bağlı)': ['Account name (optional)', 'Kontoname (optional)', 'Nom du compte (facultatif)'],
  'Sunucu adresi': ['Server address', 'Serveradresse', 'Adresse du serveur'],
  'Kullanıcı adı': ['Username', 'Benutzername', 'Nom d’utilisateur'],
  'Şifre': ['Password', 'Passwort', 'Mot de passe'],
  'Uyarı: kayıt belleği açılamadı, bilgiler kalıcı olmayabilir. ({e})': ['Warning: storage could not be opened; data may not be saved. ({e})', 'Warnung: Speicher konnte nicht geöffnet werden; Daten bleiben evtl. nicht erhalten. ({e})', 'Attention : le stockage n’a pas pu être ouvert ; les données peuvent ne pas être conservées. ({e})'],
  'Bağlan ve kaydet': ['Connect and save', 'Verbinden und speichern', 'Se connecter et enregistrer'],
  'Ara belleğe alınıyor… {a} / {b} sn': ['Buffering… {a} / {b} s', 'Puffern… {a} / {b} s', 'Mise en mémoire tampon… {a} / {b} s'],
  'Bağlantı yeniden deneniyor ({n}/5)…': ['Reconnecting ({n}/5)…', 'Verbindung wird erneut versucht ({n}/5)…', 'Nouvelle tentative de connexion ({n}/5)…'],
  'Oynatılamadı: {e}': ['Could not play: {e}', 'Wiedergabe nicht möglich: {e}', 'Lecture impossible : {e}'],
  'Favorilere eklendi': ['Added to favorites', 'Zu Favoriten hinzugefügt', 'Ajouté aux favoris'],
  'Favorilerden çıkarıldı': ['Removed from favorites', 'Aus Favoriten entfernt', 'Retiré des favoris'],
  'Geri': ['Back', 'Zurück', 'Retour'],
  'Favori': ['Favorite', 'Favorit', 'Favori'],
  'En-boy oranı': ['Aspect ratio', 'Seitenverhältnis', 'Format d’image'],
  'Tam ekran (F)': ['Fullscreen (F)', 'Vollbild (F)', 'Plein écran (F)'],
  'Otomatik': ['Auto', 'Automatisch', 'Automatique'],
  'Kapalı': ['Off', 'Aus', 'Désactivé'],
  'Parça {id}': ['Track {id}', 'Spur {id}', 'Piste {id}'],
  'Ses': ['Audio', 'Audio', 'Audio'],
  'Altyazı': ['Subtitles', 'Untertitel', 'Sous-titres'],
  'Önceki (↑)': ['Previous (↑)', 'Zurück (↑)', 'Précédent (↑)'],
  'Sonraki (↓)': ['Next (↓)', 'Weiter (↓)', 'Suivant (↓)'],
  'CANLI': ['LIVE', 'LIVE', 'DIRECT'],
  '-10 sn (←)': ['-10 s (←)', '-10 s (←)', '-10 s (←)'],
  '+10 sn (→)': ['+10 s (→)', '+10 s (→)', '+10 s (→)'],
  'Oynatıcı seç': ['Choose player', 'Player wählen', 'Choisir un lecteur'],
  'Oynatıcı açılamadı. Uygulama yüklü mü?\n({pkg})': ['Could not open the player. Is the app installed?\n({pkg})', 'Player konnte nicht geöffnet werden. Ist die App installiert?\n({pkg})', 'Impossible d’ouvrir le lecteur. L’application est-elle installée ?\n({pkg})'],
  'Seçilen oynatıcıda açılıyor…': ['Opening in the selected player…', 'Wird im gewählten Player geöffnet…', 'Ouverture dans le lecteur choisi…'],
  'Dahili oynatıcıyla aç': ['Open with built-in player', 'Mit integriertem Player öffnen', 'Ouvrir avec le lecteur intégré'],
  'Favorilerden çıkar': ['Remove from favorites', 'Aus Favoriten entfernen', 'Retirer des favoris'],
  'Favorilere ekle': ['Add to favorites', 'Zu Favoriten hinzufügen', 'Ajouter aux favoris'],
  'Bu dizi için bölüm bulunamadı.': ['No episodes found for this series.', 'Keine Folgen für diese Serie gefunden.', 'Aucun épisode trouvé pour cette série.'],
  'Puan: {r}': ['Rating: {r}', 'Bewertung: {r}', 'Note : {r}'],
  'Sezon {n}': ['Season {n}', 'Staffel {n}', 'Saison {n}'],
  'Bölüm {n}': ['Episode {n}', 'Folge {n}', 'Épisode {n}'],
  'Dahili oynatıcı (önerilen)': ['Built-in player (recommended)', 'Integrierter Player (empfohlen)', 'Lecteur intégré (recommandé)'],
  'Her seferinde sor (yüklü oynatıcılardan seç)': ['Ask every time (choose from installed players)', 'Jedes Mal fragen (aus installierten Playern wählen)', 'Demander à chaque fois (parmi les lecteurs installés)'],
  'Kanalları hangi oynatıcıda açmak istediğini seç. VLC, MX Player gibi oynatıcıların telefona/TV\'ye kurulu olması gerekir (Play Store).': ['Choose which player opens the channels. Players like VLC or MX Player must be installed on the phone/TV (Play Store).', 'Wähle, in welchem Player die Kanäle geöffnet werden. Player wie VLC oder MX Player müssen auf dem Handy/TV installiert sein (Play Store).', 'Choisis le lecteur qui ouvre les chaînes. Les lecteurs comme VLC ou MX Player doivent être installés sur le téléphone/la TV (Play Store).'],
  'Başka oynatıcı ekle': ['Add another player', 'Weiteren Player hinzufügen', 'Ajouter un autre lecteur'],
  'Oynatıcının paket adını gir (ör. org.videolan.vlc)': ['Enter the player’s package name (e.g. org.videolan.vlc)', 'Paketnamen des Players eingeben (z. B. org.videolan.vlc)', 'Saisis le nom de paquet du lecteur (ex. org.videolan.vlc)'],
  'Oynatıcı ekle': ['Add player', 'Player hinzufügen', 'Ajouter un lecteur'],
  'Ad (ör. Benim oynatıcım)': ['Name (e.g. My player)', 'Name (z. B. Mein Player)', 'Nom (ex. Mon lecteur)'],
  'Paket adı (ör. org.videolan.vlc)': ['Package name (e.g. org.videolan.vlc)', 'Paketname (z. B. org.videolan.vlc)', 'Nom du paquet (ex. org.videolan.vlc)'],
  'Ekle': ['Add', 'Hinzufügen', 'Ajouter'],
  'Hesap': ['Account', 'Konto', 'Compte'],
  'Listeleri yenile': ['Refresh lists', 'Listen aktualisieren', 'Actualiser les listes'],
  'Kanal, film ve dizi listelerini sunucudan yeniden çeker': ['Reloads channel, movie and series lists from the server', 'Lädt Kanal-, Film- und Serienlisten neu vom Server', 'Recharge les listes de chaînes, films et séries depuis le serveur'],
  'Listeler bir sonraki açılışta yenilenecek.': ['Lists will refresh on next launch.', 'Die Listen werden beim nächsten Start aktualisiert.', 'Les listes seront actualisées au prochain lancement.'],
  'Görünüm': ['Appearance', 'Darstellung', 'Apparence'],
  'Tuttuğun takım': ['Your team', 'Dein Team', 'Ton équipe'],
  '{n} — uygulama renkleri takımına göre değişir': ['{n} — app colors follow your team', '{n} — App-Farben folgen deinem Team', '{n} — les couleurs de l’app suivent ton équipe'],
  'Bitti': ['Done', 'Fertig', 'Terminé'],
  'Oynatıcı': ['Player', 'Player', 'Lecteur'],
  'Oynatıcı uygulaması': ['Player app', 'Player-App', 'Application de lecture'],
  'Canlı yayın formatı': ['Live stream format', 'Live-Stream-Format', 'Format du direct'],
  'MPEG-TS genelde daha hızlı açılır; HLS (m3u8) bazı sunucularda daha kararlıdır': ['MPEG-TS usually opens faster; HLS (m3u8) is more stable on some servers', 'MPEG-TS startet meist schneller; HLS (m3u8) ist bei manchen Servern stabiler', 'MPEG-TS démarre souvent plus vite ; HLS (m3u8) est plus stable sur certains serveurs'],
  'Donanım hızlandırma': ['Hardware acceleration', 'Hardwarebeschleunigung', 'Accélération matérielle'],
  '4K/8K için açık kalmalı. Görüntü bozuksa kapatıp dene.': ['Keep on for 4K/8K. Turn off if the picture is broken.', 'Für 4K/8K eingeschaltet lassen. Bei Bildfehlern ausschalten.', 'À garder activée pour la 4K/8K. Désactive-la si l’image est altérée.'],
  'Ara bellek': ['Buffer', 'Puffer', 'Mémoire tampon'],
  '{info} — oynatmadan önce {pre} sn biriktirir. Sık takılıyorsa yükseltin; kanal geç açılıyorsa düşürün.': ['{info} — buffers {pre} s before playing. Increase if it stutters often; lower it if channels open slowly.', '{info} — puffert {pre} s vor dem Abspielen. Bei häufigem Ruckeln erhöhen; bei langsamem Start senken.', '{info} — met {pre} s en mémoire avant la lecture. Augmente en cas de saccades ; baisse si les chaînes s’ouvrent lentement.'],
  'Düşük': ['Low', 'Niedrig', 'Faible'],
  'Normal': ['Normal', 'Normal', 'Normal'],
  'Yüksek': ['High', 'Hoch', 'Élevé'],
  'Çok yüksek': ['Very high', 'Sehr hoch', 'Très élevé'],
  'En hızlı açılış, iyi internet için': ['Fastest start, for good internet', 'Schnellster Start, für gutes Internet', 'Démarrage le plus rapide, pour une bonne connexion'],
  'Dengeli': ['Balanced', 'Ausgewogen', 'Équilibré'],
  'Takılmaya karşı, birkaç sn geç açılır': ['Against stuttering, opens a few seconds later', 'Gegen Ruckeln, startet einige Sekunden später', 'Contre les saccades, démarre quelques secondes plus tard'],
  'Zayıf/dalgalı internet için, ~15 sn geç açılır': ['For weak/unstable internet, opens ~15 s later', 'Für schwaches/instabiles Internet, startet ca. 15 s später', 'Pour une connexion faible/instable, démarre ~15 s plus tard'],
  'Yetişkin içerik': ['Adult content', 'Erwachseneninhalte', 'Contenu adulte'],
  'Kilit açık — şimdi kilitle': ['Unlocked — lock now', 'Entsperrt — jetzt sperren', 'Déverrouillé — verrouiller maintenant'],
  'Kilidi aç': ['Unlock', 'Entsperren', 'Déverrouiller'],
  'Yetişkin kategoriler PIN ile korunuyor. Uygulama arka plana alınınca otomatik kilitlenir.': ['Adult categories are PIN-protected. They lock automatically when the app goes to the background.', 'Erwachsenenkategorien sind per PIN geschützt. Sie werden automatisch gesperrt, wenn die App im Hintergrund ist.', 'Les catégories adultes sont protégées par PIN. Elles se verrouillent automatiquement quand l’app passe en arrière-plan.'],
  'Henüz PIN belirlenmedi. Kilidi açmaya çalışınca PIN oluşturulur.': ['No PIN set yet. A PIN is created when you try to unlock.', 'Noch kein PIN festgelegt. Beim Entsperren wird ein PIN erstellt.', 'Aucun PIN défini. Un PIN est créé quand tu essaies de déverrouiller.'],
  'PIN değiştir': ['Change PIN', 'PIN ändern', 'Changer le PIN'],
  'Yetişkin kategorilerini seç': ['Choose adult categories', 'Erwachsenenkategorien wählen', 'Choisir les catégories adultes'],
  'Otomatik algılananları düzeltebilir, yenilerini ekleyebilirsin': ['You can correct the auto-detected ones and add new ones', 'Automatisch erkannte kannst du korrigieren und neue hinzufügen', 'Tu peux corriger celles détectées automatiquement et en ajouter'],
  'Veri': ['Data', 'Daten', 'Données'],
  'İzleme geçmişini temizle': ['Clear watch history', 'Wiedergabeverlauf löschen', 'Effacer l’historique de visionnage'],
  'Favorileri temizle': ['Clear favorites', 'Favoriten löschen', 'Effacer les favoris'],
  'Kısayollar (Windows)': ['Shortcuts (Windows)', 'Tastenkürzel (Windows)', 'Raccourcis (Windows)'],
  'Boşluk: oynat/duraklat · F: tam ekran · M: sessiz': ['Space: play/pause · F: fullscreen · M: mute', 'Leertaste: Wiedergabe/Pause · F: Vollbild · M: stumm', 'Espace : lecture/pause · F : plein écran · M : muet'],
  '↑ / ↓: önceki / sonraki kanal · ← / →: ±10 sn · Esc: geri': ['↑ / ↓: previous / next channel · ← / →: ±10 s · Esc: back', '↑ / ↓: vorheriger / nächster Kanal · ← / →: ±10 s · Esc: zurück', '↑ / ↓ : chaîne précédente / suivante · ← / → : ±10 s · Échap : retour'],
  'Yetişkin kategorileri': ['Adult categories', 'Erwachsenenkategorien', 'Catégories adultes'],
  'Hoşgeldiniz': ['Welcome', 'Willkommen', 'Bienvenue'],
  '🌿 Doğayı sev, Hayvanları Koru 🐾': ['🌿 Love nature, protect animals 🐾', '🌿 Liebe die Natur, schütze die Tiere 🐾', '🌿 Aime la nature, protège les animaux 🐾'],
  'Takımım yok': ['No team', 'Kein Team', 'Pas d’équipe'],
  'Uygulamadan çıkılsın mı?': ['Exit the app?', 'App beenden?', 'Quitter l’application ?'],
  'Çıkarsan açık yayın da kapanır.': ['If you exit, the open stream will also stop.', 'Beim Beenden wird auch der laufende Stream gestoppt.', 'Si tu quittes, le flux en cours s’arrête aussi.'],
  'Hayır, kal': ['No, stay', 'Nein, bleiben', 'Non, rester'],
  'Evet, çık': ['Yes, exit', 'Ja, beenden', 'Oui, quitter'],
  'PIN en az 4 haneli olmalı.': ['PIN must be at least 4 digits.', 'Der PIN muss mindestens 4 Ziffern haben.', 'Le PIN doit comporter au moins 4 chiffres.'],
  'PIN\'ler eşleşmiyor.': ['PINs do not match.', 'Die PINs stimmen nicht überein.', 'Les PIN ne correspondent pas.'],
  'Yanlış PIN.': ['Wrong PIN.', 'Falscher PIN.', 'PIN incorrect.'],
  'Yetişkin PIN\'i oluştur': ['Create adult PIN', 'Erwachsenen-PIN erstellen', 'Créer le PIN adulte'],
  'Yetişkin içerik PIN\'i': ['Adult content PIN', 'PIN für Erwachseneninhalte', 'PIN du contenu adulte'],
  'Yeni PIN (en az 4 hane)': ['New PIN (min. 4 digits)', 'Neuer PIN (mind. 4 Ziffern)', 'Nouveau PIN (4 chiffres min.)'],
  'PIN (tekrar)': ['PIN (repeat)', 'PIN (wiederholen)', 'PIN (répéter)'],
  'Kaydet': ['Save', 'Speichern', 'Enregistrer'],
  'Aç': ['Unlock', 'Entsperren', 'Déverrouiller'],
  'Yukarı taşı': ['Move up', 'Nach oben', 'Monter'],
  'Aşağı taşı': ['Move down', 'Nach unten', 'Descendre'],
  'Sunucu hatası (HTTP {c})': ['Server error (HTTP {c})', 'Serverfehler (HTTP {c})', 'Erreur serveur (HTTP {c})'],
  'Sunucu geçerli bir Xtream Codes yanıtı vermedi.': ['The server did not return a valid Xtream Codes response.', 'Der Server hat keine gültige Xtream-Codes-Antwort geliefert.', 'Le serveur n’a pas renvoyé de réponse Xtream Codes valide.'],
  'Kullanıcı adı veya şifre hatalı.': ['Wrong username or password.', 'Benutzername oder Passwort falsch.', 'Nom d’utilisateur ou mot de passe incorrect.'],
  'Hesap aktif değil: {s}': ['Account is not active: {s}', 'Konto ist nicht aktiv: {s}', 'Le compte n’est pas actif : {s}'],
  'Dil / Language': ['Dil / Language', 'Dil / Language', 'Dil / Language'],
};
