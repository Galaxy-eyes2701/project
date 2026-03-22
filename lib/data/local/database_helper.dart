import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('so_tay_mam_co.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure, // bật Foreign Keys
      onCreate: _createDB,
    );
  }

  // Bật tính năng ràng buộc khóa ngoại (Foreign Key constraints)
  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    // 1. Bảng recipes (Công thức)
    await db.execute('''
      CREATE TABLE recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        image_url TEXT,
        category TEXT,
        origin TEXT,
        created_at TEXT,
        is_family_secret INTEGER DEFAULT 0
      )
    ''');

    // 2. Bảng ingredients (Nguyên liệu gốc)
    await db.execute('''
      CREATE TABLE ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        default_unit TEXT
      )
    ''');

    // 3. Bảng recipe_ingredients (Liên kết Công thức - Nguyên liệu)
    await db.execute('''
      CREATE TABLE recipe_ingredients (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER,
        ingredient_id INTEGER,
        quantity REAL,
        unit TEXT,
        note TEXT,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE,
        FOREIGN KEY (ingredient_id) REFERENCES ingredients (id) ON DELETE CASCADE
      )
    ''');

    // 4. Bảng recipe_steps (Các bước làm)
    await db.execute('''
      CREATE TABLE recipe_steps (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER,
        step_number INTEGER,
        instruction TEXT,
        duration_seconds INTEGER,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // 5. Bảng feasts (Mâm cỗ)
    await db.execute('''
      CREATE TABLE feasts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        created_at TEXT
      )
    ''');

    // 6. Bảng feast_recipes (Liên kết Mâm cỗ - Công thức)
    await db.execute('''
      CREATE TABLE feast_recipes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        feast_id INTEGER,
        recipe_id INTEGER,
        FOREIGN KEY (feast_id) REFERENCES feasts (id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    // 7. Bảng shopping_lists (Danh sách mua đồ)
    await db.execute('''
      CREATE TABLE shopping_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        created_at TEXT
      )
    ''');

    // 8. Bảng shopping_list_items (Chi tiết danh sách mua đồ)
    await db.execute('''
      CREATE TABLE shopping_list_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shopping_list_id INTEGER,
        ingredient_name TEXT,
        quantity REAL,
        unit TEXT,
        is_checked INTEGER DEFAULT 0,
        FOREIGN KEY (shopping_list_id) REFERENCES shopping_lists (id) ON DELETE CASCADE
      )
    ''');

    // 9. Bảng family_tips (Bí kíp gia truyền)
    await db.execute('''
      CREATE TABLE family_tips (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        recipe_id INTEGER,
        title TEXT,
        content TEXT,
        is_secret INTEGER DEFAULT 1,
        created_at TEXT,
        FOREIGN KEY (recipe_id) REFERENCES recipes (id) ON DELETE CASCADE
      )
    ''');

    await _seedData(db);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
  Future _seedData(Database db) async {
    final now = DateTime.now().toIso8601String();

    // 1. Thêm 7 Công thức (Recipes) kinh điển ngày Tết
    await db.rawInsert('''
      INSERT INTO recipes (id, name, description, category, is_family_secret, created_at)
      VALUES 
      (1, 'Gà luộc ngậm hoa hồng', 'Món gà trống thiến luộc cúng Giao thừa, da vàng ươm, dáng rồng bay.', 'Món luộc', 1, '$now'),
      (2, 'Bánh chưng xanh', 'Bánh chưng gói lá dong, dền gạo, xanh vỏ, nhân thịt mỡ đậu xanh bùi béo.', 'Món chính', 0, '$now'),
      (3, 'Canh măng khô móng giò', 'Bát canh măng nứa ninh móng giò nhừ tơi, ngọt thanh, chống ngán ngày Tết.', 'Món canh', 0, '$now'),
      (4, 'Nem rán Hà Nội', 'Nem rán vỏ giòn rụm, nhân thịt mộc nhĩ nấm hương thơm lừng.', 'Món chiên', 1, '$now'),
      (5, 'Xôi gấc đỏ tươi', 'Đĩa xôi gấc đỏ mang ý nghĩa may mắn, tài lộc đầu năm.', 'Món xôi', 0, '$now'),
      (6, 'Thịt đông mộc nhĩ', 'Thịt chân giò và tai heo nấu đông, ăn kèm dưa hành cực kỳ đưa cơm.', 'Món kho/đông', 1, '$now'),
      (7, 'Dưa hành muối chua', 'Món ăn kèm "bất hủ" giải ngán, củ hành trắng muốt, giòn tan không bị hăng.', 'Món muối', 1, '$now')
    ''');

    // 2. Thêm Các bước làm (Recipe Steps) với thời lượng (giây)
    await db.rawInsert('''
      INSERT INTO recipe_steps (recipe_id, step_number, instruction, duration_seconds)
      VALUES 
      -- Gà luộc (1)
      (1, 1, 'Làm sạch gà, buộc cánh tiên, xát muối hột khử mùi. Cho vào nồi ngập nước lạnh.', 600),
      (1, 2, 'Đun lửa vừa đến khi sôi, hớt bọt. Cho hành nướng, gừng đập dập, hạ nhỏ lửa.', 1200),
      (1, 3, 'Tắt bếp, ngâm gà trong nồi thêm 15 phút để thịt chín thấu. Vớt ra nhúng nước đá để da giòn.', 900),
      -- Bánh chưng (2)
      (2, 1, 'Ngâm nếp cái hoa vàng, đậu xanh qua đêm. Rửa sạch lá dong, lau khô. Ướp thịt mỡ với tiêu, hành.', 3600),
      (2, 2, 'Xếp lá dong, rải 1 lớp gạo, 1 lớp đỗ, 1 miếng thịt, lại đỗ, lại gạo. Gói chặt tay, lạt giang buộc chéo.', 1800),
      (2, 3, 'Xếp cuống lá xuống đáy nồi, cho bánh vào luộc ngập nước lửa to liên tục 10-12 tiếng. Vớt ra ép ráo nước.', 43200),
      -- Canh măng móng giò (3)
      (3, 1, 'Măng khô ngâm nước gạo 2 ngày, luộc xả nhiều lần đến khi nước trong. Xé sợi vừa ăn.', 7200),
      (3, 2, 'Móng giò chặt miếng, chần nước sôi khử bẩn. Xào săn móng giò với mắm muối.', 900),
      (3, 3, 'Xào măng thấm gia vị. Cho móng giò và măng vào nồi áp suất ninh nhừ. Thêm hành mùi khi múc ra bát.', 3600),
      -- Xôi gấc (5)
      (5, 1, 'Bổ gấc, lấy ruột bóp với chút rượu trắng để lên màu đỏ tươi. Trộn đều với gạo nếp đã ngâm.', 900),
      (5, 2, 'Cho lên chõ đồ xôi chín tới. Mở vung rưới thêm chút mỡ gà và đường cho hạt xôi bóng bẩy.', 2400),
      -- Thịt đông (6)
      (6, 1, 'Thái hạt lựu thịt chân giò, tai heo, bì heo. Xào săn với nước mắm, tiêu sọ, mộc nhĩ thái vụn.', 1200),
      (6, 2, 'Đổ ngập nước, ninh liu riu hớt bọt liên tục để nước trong vắt. Múc ra bát, để vào tủ lạnh cho đông.', 5400)
    ''');

    // 3. Thêm 3 Mâm cỗ (Feasts) đặc trưng
    await db.rawInsert('''
      INSERT INTO feasts (id, name, description, created_at)
      VALUES 
      (1, 'Mâm cỗ Tất niên (Chiều 30)', 'Mâm cỗ "4 bát 6 đĩa" truyền thống, sum họp gia đình ngày cuối năm.', '$now'),
      (2, 'Mâm cỗ Giao thừa (Ngoài trời)', 'Cúng dâng sao giải hạn, tạ ơn các quan hành khiển.', '$now'),
      (3, 'Mâm cỗ Tân niên (Mùng 1 Tết)', 'Mâm cỗ thanh tịnh ngày mùng 1 cầu bình an, may mắn.', '$now')
    ''');

    // 4. Phân bổ món ăn vào các Mâm cỗ
    await db.rawInsert('''
      INSERT INTO feast_recipes (feast_id, recipe_id)
      VALUES 
      -- Tất niên: Đầy đủ nhất (Bánh chưng, Gà, Canh măng, Nem, Xôi, Thịt đông, Dưa hành)
      (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7),
      -- Giao thừa: Gọn nhẹ tinh khiết (Gà ngậm hoa hồng, Bánh chưng, Xôi gấc)
      (2, 1), (2, 2), (2, 5),
      -- Mùng 1: Thanh tịnh (Bánh chưng, Canh măng, Nem rán, Dưa hành)
      (3, 2), (3, 3), (3, 4), (3, 7)
    ''');

    // 5. Thêm Danh sách đi chợ
    await db.rawInsert('''
      INSERT INTO shopping_lists (id, name, created_at)
      VALUES 
      (1, 'Đồ khô (Sắm rằm tháng Chạp)', '$now'),
      (2, 'Đồ tươi (Đi chợ sáng 30 Tết)', '$now')
    ''');

    // 6. Thêm các món đồ cần mua thực tế
    await db.rawInsert('''
      INSERT INTO shopping_list_items (shopping_list_id, ingredient_name, quantity, unit, is_checked)
      VALUES 
      -- Đồ khô (List 1)
      (1, 'Gạo nếp cái hoa vàng', 5, 'kg', 1), -- Đã mua
      (1, 'Măng nứa khô', 1, 'kg', 1),
      (1, 'Miến dong, mộc nhĩ, nấm hương', 3, 'gói', 1),
      (1, 'Lá dong, lạt giang gói bánh', 100, 'lá', 0),
      -- Đồ tươi (List 2)
      (2, 'Gà trống thiến (bắt sống)', 2.5, 'kg', 0),
      (2, 'Móng giò heo', 2, 'chiếc', 0),
      (2, 'Thịt vai sấn xay (làm nem)', 500, 'gram', 0),
      (2, 'Gấc tươi chín đỏ', 1, 'quả', 0),
      (2, 'Hành củ, rau mùi, chanh, ớt', 2, 'mớ', 0)
    ''');
  }
}