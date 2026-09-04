extends Node		

var aktif_kullanici = null
var aktif_ogrenci_no: String = "102"
var mevcut_kullanici: Dictionary = {}
var gano: float = 0.0

var secilen_dersler: Array = []
var alinan_dersler: Array = []
var gecmis_talepler: Array = []
				
var tum_kullanicilar = [
	{
		"ogrenci_no":"101",
		"sifre":"12",
		"tc_no": "11111111111",
		"ad": "ahmet",
		"bolumu": "Bilgisayar Mühendisliği",
		"programi": "Lisans",
		"durumu": "Aktif",
		"mezuniyet": "Devam Ediyor",
		"resim": "res://images/resim3.png"
	},
	{
		"ogrenci_no": "102",
		"sifre":"13",
		"tc_no": "22222222222",
		"ad": "zeynep",
		"bolumu": "Yazılım Mühendisliği",
		"programi": "Yüksek Lisans",
		"durumu": "Pasif",
		"mezuniyet": "Mezun",
		"resim": "res://images/resim4.png"
	},
	{
		"ogrenci_no": "103",
		"sifre":"14",
		"tc_no": "33333333333",
		"ad": "Hasan",
		"bolumu": "Makina Mühendisliği",
		"programi": "Yüksek Lisans",
		"durumu": "Pasif",
		"mezuniyet": "Mezun",
		"resim": "res://images/resim5.png"
	},
	{
		"ogrenci_no": "104",
		"sifre":"15",
		"tc_no": "55555555555",
		"ad": "Esma Gül",
		"bolumu": "Bilgisayar Mühendisliği",
		"programi": "Yüksek Lisans",
		"durumu": "Aktif",
		"mezuniyet": "Mezun değil",
		"resim": "res://images/resim6.png"
	},
	{
		"ogrenci_no": "105",
		"sifre":"16",
		"tc_no": "66666666666",
		"ad": "Burhan",
		"bolumu": "Bilgisayar Mühendisliği",
		"programi": "Yüksek Lisans",
		"durumu": "Pasif",
		"mezuniyet": "Mezun",
		"resim": "res://images/resim7.png"
	}
]

var ogrenci_verileri = [
	{"numarasi":"101", "sifre":"12"},
	{"numarasi":"102", "sifre":"13"},
	{"numarasi": "103", "sifre":"14"},
	{"numarasi": "104", "sifre":"15"},
	{"numarasi": "105", "sifre": "16"}
]

var ogrenci_numarasi: String = ""
var ogrenci_adi: String = ""



#--- 2. AKADEMİK VERİLER ---
var acilan_dersler: Array = [
	{"kod": "BIL101", "ad": "Programlamaya Giriş", "akts": "4", "gun": "Pazartesi", "saat": "10.45 - 11.30", "derslik": "A-101"},
	{"kod": "BIL102", "ad": "Algoritmalar", "akts": "7.5", "gun": "Salı", "saat": "8.55 - 9.40", "derslik": "C-105"},
	{"kod": "BIL103", "ad": "Veritabanı Yönetim Sistemleri", "akts": "6", "gun": "Perşembe", "saat": "13.20 - 14.15", "derslik": "Amfi-2"},
	{"kod": "BIL104", "ad": "Nesneye Yönelik Programlama", "akts": "5", "gun": "Cuma", "saat": "9.50 - 10.35", "derslik": "B-102"},
	{"kod": "BIL105", "ad": "Diller", "akts": "4", "gun": "Pazartesi", "saat": "14.25 - 15.10", "derslik": "B-201"},
	{"kod": "BIL106", "ad": "Sayısal çözümleme", "akts": "3", "gun": "Çarşamba", "saat": "8.55 - 9.40", "derslik": "C-101"},
	{"kod": "BIL107", "ad": "Sayısal sistemler", "akts": "3", "gun": "Salı", "saat": "11.40 - 12.25", "derslik": "Amfi-1"},
	{"kod": "BIL108", "ad": "Veri yapıları", "akts": "2", "gun": "Çarşamba", "saat": "12.25 - 13.10", "derslik": "B-204"},
	{"kod": "BIL109", "ad": "İşletim Sistemleri", "akts":"5.5", "gun":"Cuma", "saat":"8.55 - 9.40", "derslik":"A-109"},
	{"kod": "BIL110", "ad":"Seçmeli1", "akts":"1.5", "gun":"Salı", "saat":"15.20 - 16.05", "derslik":"R-245" },
	{"kod": "BIL111", "ad": "Seçmeli2", "akts":"2", "gun":"Çarşamba", "saat": "15.20 - 16.05", "derslik":"E-133"},
	{"kod":"BIL112", "ad": "Kariyer Planlama", "akts":"1.5", "gun":"Perşembe", "saat":"15.20 - 16.05", "derslik":"T-143"},
	{"kod":"ING", "ad":"İngilizce", "akts":"2.5", "gun":"Salı", "saat" : "11.40 - 12.25","derslik":"R-122" }
]



# --- 3. TALEP VE ÖDEME ---
#var gecmis_talepler: Array = []
var  harc_borcu: float = 1250.00
var borc_odendi_mi: bool = false

var odemeBilgileri = [
	{"ogrenci_no":"101", "miktar":"5000", "son_odeme":"15.09.2026"},
	{"ogrenci_no":"102", "miktar":"-", "son_odeme":"-"}
]

var gecerli_kartlar = ["111111"]

# --- 4. YARDIMCI VE MANTIKSAL FONKSİYONLAR ---

func kullanici_bul_by_id(hedef_id: String):
	for k in tum_kullanicilar:
		if str(k["ogrenci_no"]) == str(hedef_id):
			return k
	return null

func kullanici_girisi_yap(kullanici_bilgisi: Dictionary, ders_listesi: Array = []) -> void:
	mevcut_kullanici = kullanici_bilgisi
	aktif_kullanici = kullanici_bilgisi
	aktif_ogrenci_no = str(kullanici_bilgisi.get("ogrenci_no", "101"))
	if ders_listesi.size() > 0:
		acilan_dersler = ders_listesi
		gano_hesapla()

func ogrenci_ders_notu_getir(p_ogrenci_no: String, p_ders_adi: String, p_ders_kodu: String = "") -> String:
	for ders in alinan_dersler:
		if str(ders.get("ogrenci_no", "")) == p_ogrenci_no:
			var d_ad = str(ders.get("ad", "")).to_lower()
			var d_kod = str(ders.get("kod", "")).to_lower()
			
			if (p_ders_kodu != "" and d_kod == p_ders_kodu.to_lower()) or d_ad == p_ders_adi.to_lower():
				return ders.get("harf_notu", "BA") 	
	return "AA"
	

func talep_ekle(belge_adi: String, dil: String):
	var dt = Time.get_date_dict_from_system()
	var bugun = "%02d.%02d.%d" % [dt["day"], dt["month"], dt["year"]]
	
	var yeni_item = {"ogrenci_no":aktif_ogrenci_no, "tarih": bugun, "belge":belge_adi + " (" + dil + ")", "durum": "Onay Bekliyor"}
	gecmis_talepler.append(yeni_item)

# --- 5. GANO HESAPLAMA ---
func gano_hesapla() -> void:
	var toplam_agirlikli_not = 0.0
	var toplam_akts = 0.0

	for ders in alinan_dersler:
	# Ortalama Hesaplama: Vize %40 + Final %60
		if str(ders.get("ogrenci_no", "")) == aktif_ogrenci_no:
			var harf = str(ders.get("harf_notu", "AA")).to_upper()
			var akts_degeri = float(ders.get("akts", 0))
			var katsayi = 0.0
			match harf:
				"AA": katsayi = 4.0
				"BA": katsayi = 3.5
				"BB": katsayi = 3.0
				"CB": katsayi = 2.5
				"CC": katsayi = 2.0
				"DC": katsayi = 1.5
				"DD": katsayi = 1.0
				"FF": katsayi = 0.0
				_: katsayi = 4.0 #varsayilan
				
			toplam_agirlikli_not += katsayi * akts_degeri
			toplam_akts += akts_degeri

	if toplam_akts > 0:
		gano = toplam_agirlikli_not / toplam_akts
	else:
		gano = 0.0
		
# --- 6.DUYURULAR İÇİN LİSTE ---
var duyurular: Array = [
	{
		"baslik": "Ders Kayıtları Başladı", 
		"tarih": "15.02", 
		"icerik": "2026 Güz dönemi ders kayıtları açılmıştır. Tüm öğrencilerin danışman onayına göndermesi gerekmektedir."
	},
	{
		"baslik": "Yaz Okulu Başvuruları", 
		"tarih": "10.06", 
		"icerik": "Yaz okulunda açılacak dersler ilan edilmiştir. Dilekçelerinizi 18 Haziran'a kadar öğrenci işlerine teslim ediniz."
	},
	{
		"baslik": "Büt Sınav Takvimi", 
		"tarih": "01.07", 
		"icerik": "Bütünleme sınav tarihleri ve derslik bilgileri portal üzerinden güncellenmiştir."
	},
	{
		"baslik": "Oryantasyon Programı", 
		"tarih": "15.09", 
		"icerik": "Yeni kazanan öğrenciler için oryantasyon programı Eylülde ana amfide yapılacaktır."
	},
	{
		"baslik": "Yemekhane Burs Sonuçları", 
		"tarih": "20.10", 
		"icerik": "Ücretsiz yemek bursu almaya hak kazanan öğrencilerin listesi ilan edilmiştir."
	}
]

var sinavlar: Array = [
	{"ders_adi": "Programlamaya Giriş", "ders_kodu": "BIL101", "tur": "vize", "derslik": "101", "tarih": "19.08.2026", "saat": "14.00"},
	{"ders_adi": "Algoritmalar", "ders_kodu": "BIL102", "tur": "vize", "derslik": "102", "tarih": "21.08.2026", "saat": "10.00"},
	{"ders_adi": "Veritabanı Yönetim Sistemleri", "ders_kodu": "BIL103", "tur": "vize", "derslik": "103", "tarih": "23.08.2026", "saat": "11.30"}
]
# --- Devamsızlık için ---
# GlobalData.gd içinde:
var devamsizliklar: Array = [
	{
		"ogrenci_no" : "101",
		"ders_kodu": "BIL101",
		"ders_adi": "Programlamaya Giriş",
		"devamsizlik_saati": 4, # Öğrencinin bireysel devamsızlığı
		"toplam_saat": 40,
		"zorunluluk_yuzdesi": 80
	},
	{
		"ogrenci_no" : "102",
		"ders_kodu": "BIL102",
		"ders_adi": "Algoritmalar",
		"devamsizlik_saati": 10,
		"toplam_saat": 40,
		"zorunluluk_yuzdesi": 80
	}
]	

''' DANIŞMALA İLGİLİ DİZİ'''

var danısman = [
	{
		"ogrenci_no": "102",
		"Danisman isim": "Prof. Dr. Mehmet Doğdu",
		"resmi":"res://images/resim4.png" ,
		"mail": "Danisman@universite.edu.tr",
		"bolumu": "Elektrik Mühendisliği",  # Dikkat: "bolumu" anahtar adı
		"ofisi": "B-Blok, Kat: 2, No: 204",
		"ofisTel": "0253 10 14"
	},
	{
		"ogrenci_no": "103",
		"Danisman isim": "Prof. Dr. Mehmet Doğdu",
		"resmi":"res://images/resim4.png" ,
		"mail": "Danisman@universite.edu.tr",
		"bolumu": "Elektrik Mühendisliği",  # Dikkat: "bolumu" anahtar adı
		"ofisi": "B-Blok, Kat: 2, No: 204",
		"ofisTel": "0253 10 14"
	},
	{
		"ogrenci_no": "105",
		"Danisman isim": "Prof. Dr. Mehmet Doğdu",
		"resmi":"res://images/resim4.png" ,
		"mail": "Danisman@universite.edu.tr",
		"bolumu": "Elektrik Mühendisliği",  # Dikkat: "bolumu" anahtar adı
		"ofisi": "B-Blok, Kat: 2, No: 204",
		"ofisTel": "0253 10 14"
	},
	{
		"ogrenci_no": "104",
		"Danisman isim": "Prof. Dr. Firdevs Kaya",
		"resmi": "res://images/resim1.png",
		"mail": "Danisman@universite.edu.tr",
		"bolumu": "Bilgisayar Mühendisliği",  # Dikkat: "bolumu" anahtar adı
		"ofisi": "A-Blok, Kat: 3, No: 144",
		"ofisTel": "0253 45 12"
	},
	{
		"ogrenci_no": "101",
		"Danisman isim": "Prof. Dr. Firdevs Kaya",
		"resmi": "res://images/resim1.png",
		"mail": "Danisman@universite.edu.tr",
		"bolumu": "Bilgisayar Mühendisliği",  # Dikkat: "bolumu" anahtar adı
		"ofisi": "A-Blok, Kat: 3, No: 144",
		"ofisTel": "0253 45 12"
	}
]

func aktif_danisman_bilgisi_getir() -> Dictionary:
	var aktif_no = str(aktif_ogrenci_no) # "101" veya "102"
	
	for d in danısman:
		if str(d.get("ogrenci_no", "")) == aktif_no:
			return d # Doğru danışman bilgilerini döndürür
			
	print("HATA: ", aktif_no, " numaralı öğrenci için danışman bulunamadı!")
	return {}
