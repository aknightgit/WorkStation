/// 麻将牌类型
enum TileType {
  // 万子 (1-9)
  wan1, wan2, wan3, wan4, wan5, wan6, wan7, wan8, wan9,
  // 筒子 (1-9)
  tong1, tong2, tong3, tong4, tong5, tong6, tong7, tong8, tong9,
  // 条子 (1-9)
  tiao1, tiao2, tiao3, tiao4, tiao5, tiao6, tiao7, tiao8, tiao9,
  // 风牌
  dong, nan, xi, bei,
  // 箭牌
  zhong, fa, bai,
  // 花牌 (8张)
  hua_mei, hua_lan, hua_zhu, hua_ju,
  hua_chun, hua_xia, hua_qiu, hua_dong,
}

/// 花色分类
enum TileSuit {
  wan,   // 万
  tong,  // 筒
  tiao,  // 条
  feng,  // 风
  jian,  // 箭
  hua,   // 花
}

/// 牌面属性
class Tile {
  final TileType type;
  final int id;  // 唯一ID，用于区分每张牌

  Tile({
    required this.type,
    required this.id,
  });

  /// 获取花色
  TileSuit get suit {
    if (type.index >= 0 && type.index <= 8) return TileSuit.wan;
    if (type.index >= 9 && type.index <= 17) return TileSuit.tong;
    if (type.index >= 18 && type.index <= 26) return TileSuit.tiao;
    if (type.index >= 27 && type.index <= 30) return TileSuit.feng;
    if (type.index >= 31 && type.index <= 33) return TileSuit.jian;
    return TileSuit.hua;
  }

  /// 获取数字值 (万/筒/条 1-9, 风/箭 1-4/1-3, 花 1-8)
  int get number {
    if (suit == TileSuit.wan) return type.index - 0 + 1;
    if (suit == TileSuit.tong) return type.index - 9 + 1;
    if (suit == TileSuit.tiao) return type.index - 18 + 1;
    if (suit == TileSuit.feng) return type.index - 27 + 1;
    if (suit == TileSuit.jian) return type.index - 31 + 1;
    if (suit == TileSuit.hua) return type.index - 34 + 1;
    return 0;
  }

  /// 判断两张牌是否相同花色（万/筒/条内部）
  bool isSameSuit(Tile other) {
    if (!isXuPai || !other.isXuPai) return false;
    return (suit == other.suit);
  }

  /// 判断是否同花色同数值
  bool isSameType(Tile other) {
    return type == other.type;
  }

  /// 是否为风牌
  bool get isFeng => suit == TileSuit.feng;

  /// 是否为箭牌
  bool get isJian => suit == TileSuit.jian;

  /// 是否为花牌
  bool get isHua => suit == TileSuit.hua;

  /// 是否为序牌 (万/筒/条)
  bool get isXuPai => suit == TileSuit.wan || suit == TileSuit.tong || suit == TileSuit.tiao;

  /// 是否为字牌 (风/箭)
  bool get isZiPai => isFeng || isJian;

  /// 获取素材路径
  String get imagePath {
    String baseName = type.name;
    return 'assets/images/tiles/$baseName.png';
  }

  /// 显示名称
  String get displayName {
    final names = {
      TileSuit.wan: '万',
      TileSuit.tong: '筒',
      TileSuit.tiao: '条',
      TileSuit.feng: '东南西北',
      TileSuit.jian: '中发白',
      TileSuit.hua: '花',
    };
    
    if (suit == TileSuit.feng) {
      const fengNames = ['东', '南', '西', '北'];
      return fengNames[number - 1];
    }
    if (suit == TileSuit.jian) {
      const jianNames = ['中', '发', '白'];
      return jianNames[number - 1];
    }
    if (suit == TileSuit.hua) {
      const huaNames = ['梅', '兰', '竹', '菊', '春', '夏', '秋', '冬'];
      return huaNames[number - 1];
    }
    return '$number${names[suit]}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tile && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => displayName;
}
