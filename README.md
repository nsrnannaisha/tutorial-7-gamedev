# Tutorial Game Development 🎮
Nama  : Nisrina Annaisha Sarnadi  
NPM   : 2306275960

## Tutorial 7 - Basic 3D Game Mechanics & Level Design

### Basic 3D Plane Movement

#### Struktur Scene Player
- Dibuat scene baru `Player.tscn` dengan root node `CharacterBody3D`
- Child node yang ditambahkan: `MeshInstance3D`, `CollisionShape3D`, `Head` (Node3D), dan `Camera3D` sebagai child dari `Head`
- `CapsuleShape` diassign pada `CollisionShape3D` melalui tab Inspector sebagai collision player
- `CapsuleMesh` diassign pada `MeshInstance3D` sebagai tampilan visual player
- Node `Head` diposisikan di ujung atas objek agar kamera berada di posisi kepala player

#### Script Player
- Script di-attach pada node `CharacterBody3D`
- Mouse di-capture menggunakan `Input.MOUSE_MODE_CAPTURED` pada `_ready()` agar kamera dapat dikendalikan mouse
- Pergerakan menggunakan `head.basis.z` dan `head.basis.x` agar arah gerak mengikuti arah pandangan kamera
- `movement_vector.normalized()` digunakan agar kecepatan tidak bertambah saat bergerak diagonal
- Fungsi `lerp` digunakan pada `velocity.x` dan `velocity.z` agar pergerakan terasa mulus sesuai nilai `acceleration`
- Gravity diterapkan secara manual dengan mengurangi `velocity.y` setiap frame saat player tidak berada di lantai
- Fungsi `move_and_slide()` dipanggil di akhir `_physics_process` untuk menggerakkan player

#### Input Map
Memastikan Action berikut ada di **Project > Project Settings > Input Map**:
  - `movement_forward` → W
  - `movement_backward` → S
  - `movement_left` → A
  - `movement_right` → D
  - `jump` → Space
  - `interact` → E

### Object Interaction

#### Interactable.gd
- Script `Interactable.gd` dibuat sebagai base class dengan `class_name Interactable`
- Berisi fungsi `interact()` kosong yang akan di-override oleh class turunan
- File ini tidak di-attach ke node manapun, hanya berfungsi sebagai definisi class

#### Switch.gd
- Script `Switch.gd` meng-extend `Interactable` dan di-attach ke node `StaticBody3D` pada objek switch
- Export variable `light` bertipe `NodePath` digunakan untuk mereferensikan node `OmniLight3D` dari Inspector
- Fungsi `interact()` di-override untuk toggle variabel `on` dan mengubah `light_energy` pada `OmniLight3D`
- Saat lampu menyala, `light_energy` diset ke 10; saat mati diset ke 3
- Node `OmniLight3D` di-assign pada variabel `Light` di Inspector

#### RayCast3D
- Node `RayCast3D` ditambahkan sebagai child dari `Camera3D` dengan **Enabled: On**
- Target Position diset ke `z = -1` agar raycast mengarah ke depan kamera sejauh 1 unit
- Script di-attach pada `RayCast3D` untuk mengecek apakah objek yang disentuh merupakan `Interactable`
- Saat tombol `interact` (E) ditekan dan raycast menyentuh `Interactable`, fungsi `interact()` dipanggil

### Level 3D dengan CSG

#### New Room
- Scene `World1.tscn` dibuat dengan root node `Node3D`
- `CSGBox3D` bernama `Room1` ditambahkan sebagai child dengan **Flip Faces: On** agar tampak seperti ruangan kosong dari dalam
- **Use Collision** diaktifkan agar player tidak jatuh menembus lantai
- Ukuran room diatur melalui Width, Height, Depth di Inspector

#### Objek Lampu (ObjLamp)
- Scene `ObjLamp.tscn` dibuat dengan `CSGCombiner3D` bernama `lamp` sebagai root
- **Use Collision** diaktifkan pada `CSGCombiner3D`
- Bagian alas dibuat menggunakan `CSGCylinder3D` dengan **Cone: On**
- Tiang dibuat menggunakan `CSGCylinder3D` dengan radius kecil dan height panjang
- Penutup lampu dibuat menggunakan `CSGPolygon3D` dengan **Mode: Spin**, titik polygon diatur membentuk trapesium di Front View
- Warna penutup lampu diatur menggunakan **New StandardMaterial3D** → Albedo → Color
- Scene `ObjLamp.tscn` di-instance ke dalam `World1.tscn` melalui **Instance Child Scene**

#### Adding Obstacles
- `CSGCombiner3D` baru dibuat di dalam `World1` dengan **Use Collision: On**
- Node `Room1` dipindahkan ke dalam `CSGCombiner3D`
- `CSGBox3D` kedua ditambahkan untuk ruangan baru dengan **Operation: Union** dan **Flip Faces: On**
- `CSGBox3D` ketiga ditambahkan sebagai jurang dengan **Operation: Subtraction** agar memotong lantai
- Tiga `CSGBox3D` ditambahkan di luar `CSGCombiner3D` sebagai batu loncatan dengan **Use Collision: On**

#### Goal Condition
- Scene `AreaTrigger.tscn` dibuat dengan root node `Area3D`
- `CollisionShape3D` dengan bentuk **box** ditambahkan sebagai child
- Signal `body_entered` disambungkan ke fungsi yang mengecek apakah body yang masuk bernama `Player`
- Export variable `sceneName` digunakan untuk menentukan scene tujuan dari Inspector
- AreaTrigger  diletakkan di bawah jurang dengan `sceneName = "Level1"` agar scene reload saat player jatuh

### Sprinting & Crouching

#### Variabel Baru
- `sprint_speed` (18.0) dan `crouch_speed` (4.0) ditambahkan sebagai export variable
- `is_crouching` ditambahkan sebagai variabel boolean untuk tracking status crouch
- `normal_height` dan `crouch_height` menyimpan tinggi collision shape saat normal dan crouch
- `normal_head_y` dan `crouch_head_y` menyimpan posisi head saat normal dan crouch

#### Input Map
- Action berikut ditambahkan di **Project > Project Settings > Input Map**:
  - `sprint` → Left Shift
  - `crouch` → Left Ctrl

#### Logika Sprint & Crouch
- Saat `sprint` ditekan dan player tidak sedang crouch, `current_speed` diganti ke `sprint_speed`
- Saat `crouch` ditekan:
  - `is_crouching` diset ke `true`
  - `collision.shape.height` diperkecil ke `crouch_height`
  - Posisi `head` diturunkan ke `crouch_head_y` agar kamera ikut turun
- Saat `crouch` dilepas, collision shape dan posisi head dikembalikan ke nilai normal
- Player tidak dapat melompat saat `is_crouching` bernilai `true`
- `current_speed` digunakan pada `velocity.x` dan `velocity.z` agar kecepatan berubah sesuai state

### HUD

#### Struktur Scene
- `CanvasLayer` ditambahkan sebagai child dari node `Player`
- Node `Control` bernama `HUD` ditambahkan sebagai child dari `CanvasLayer`

#### State Indicator
- Node `Label` bernama `StateLabel` ditambahkan sebagai child dari `HUD`
- **Anchors Preset** diset ke **Bottom Left**
- Script Player diupdate untuk menampilkan teks `SPRINT` saat berlari, `CROUCH` saat jongkok, dan kosong saat berjalan normal
- `@onready var state_label` ditambahkan untuk mereferensikan node `StateLabel`

### Referensi
- [Godot 3D Tutorial](https://docs.godotengine.org/en/stable/tutorials/3d/index.html)
- [Godot FPS Tutorial](https://docs.godotengine.org/en/stable/tutorials/3d/fps_tutorial/index.html)

### Asset
- [Texture Image](https://www.istockphoto.com/photos/pink-texture)
