# เริ่มต้นใช้งาน RF Vision Enterprise กับ Codex

แพ็กเกจนี้จัดโครงสร้างไว้ให้แตกไฟล์แล้วเริ่มงานได้ทันที โดยไม่ต้องย้ายไฟล์ภายในเอง

## ตำแหน่งที่ถูกต้อง

แตก ZIP ลงในโฟลเดอร์:

```text
~/Resolver/Projects
```

หลังแตกไฟล์ต้องได้:

```text
~/Resolver/Projects/RFVisionEnterprise
```

ตรวจสอบด้วย Terminal:

```bash
cd ~/Resolver/Projects/RFVisionEnterprise
pwd
ls -la
```

ควรเห็น `AGENTS.md`, `README.md`, `Codex/`, `Documents/`, `Scripts/`, `RFVisionEnterprise.xcodeproj` และ `RFVisionEnterprise/`

## เริ่ม Git repository

กรณียังไม่ได้สร้าง GitHub repository ให้สร้าง **Private repository** ชื่อ `RFVisionEnterprise` โดยไม่ต้องเพิ่ม README, .gitignore หรือ License จาก GitHub ก่อน จากนั้นรัน:

```bash
cd ~/Resolver/Projects/RFVisionEnterprise
chmod +x Scripts/*.sh
./Scripts/bootstrap-git.sh
```

Script จะ initialize Git และสร้าง commit แรก แต่จะไม่ใส่ remote ให้อัตโนมัติ

เพิ่ม GitHub remote ภายหลัง:

```bash
git remote add origin https://github.com/<ACCOUNT>/RFVisionEnterprise.git
git branch -M main
git push -u origin main
```

## เปิด Codex

เปิด Codex โดยตั้ง workspace/root directory เป็น:

```text
~/Resolver/Projects/RFVisionEnterprise
```

จากนั้นส่ง prompt จากไฟล์:

```text
Codex/CODEX_START_PROMPT.md
```

Codex ต้องอ่าน `AGENTS.md` ก่อนเริ่มแก้ไขไฟล์ใด ๆ

## ข้อควรระวัง

- ห้าม commit Mist API token, Organization ID จริง หรือ provisioning profile
- อย่าลบ `Documents/` และ `Codex/` เพราะเป็นข้อกำหนดหลักของโปรเจกต์
- Build status ของ baseline ยังต้องยืนยันบนเครื่องที่มี Xcode จริง
- งานแรกของ Codex คือทำให้ build ผ่านบน iOS Simulator และ macOS โดยยังไม่เพิ่ม feature ใหม่
