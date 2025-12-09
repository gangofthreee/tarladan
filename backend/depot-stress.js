import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
    // ⚠️ KRİTİK AYAR: SSL Sertifika kontrolünü kapatıyoruz.
    // Nginx'in self-signed sertifikasına "Güven, sorun yok" diyoruz.
    insecureSkipTLSVerify: true,

    // Test Süresi
    duration: '180s', 
    
    // Eş zamanlı kullanıcı sayısı
    vus: 5000,       
};

export default function () {
    // Her istek için benzersiz bir sayı
    const uniqueId = `${__VU}_${__ITER}`; 

    const payload = JSON.stringify({
        address: `Stres Mah. Test Sok. No:${uniqueId}`,
        sizeM2: 500,
        capacityTon: 1000,
        price: 5000.0
    });

    const params = {
        headers: {
            'Content-Type': 'application/json',
        },
    };

    // İsteği gönder (http olarak atsan da Nginx https'e yönlendirecek, 
    // yukarıdaki ayar sayesinde k6 bunu kabul edecek)
    const res = http.post('https://localhost/depot/create', payload, params);
    // Başarılı mı? (200 OK veya 201 Created)
    check(res, {
        'Depot Created': (r) => r.status === 200 || r.status === 201,
    });
    
    // Hata alırsan terminale yazdır
    if (res.status !== 200 && res.status !== 201) {
       // Hata mesajını kısaltarak yazdıralım ki terminal kilitlenmesin
       console.error(`Hata Kodu: ${res.status} - Mesaj: ${res.body ? res.body.toString().substring(0, 100) : "Yok"}`);
    }

    sleep(0.5); 
}