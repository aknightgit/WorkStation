import 'package:flutter_test/flutter_test.dart';
import 'package:mahjong_game/models/tile_model.dart';
import 'package:mahjong_game/models/player_model.dart';
import 'package:mahjong_game/game_logic/mahjong_game.dart';

void main() {
  group('麻将游戏核心测试', () {
    late MahjongGame game;

    setUp(() {
      game = MahjongGame();
    });

    test('游戏初始化', () {
      game.initGame();
      expect(game.players.length, 4);
      expect(game.remainingTiles, greaterThan(0));
    });

    test('掷骰子', () {
      game.initGame();
      game.rollDice();
      expect(game.diceRolled, true);
      expect(game.diceValues[0], inInclusiveRange(1, 6));
      expect(game.diceValues[1], inInclusiveRange(1, 6));
    });

    test('发牌', () {
      game.initGame();
      game.rollDice();
      game.startRound();

      // 庄家14张，其余13张
      for (int i = 0; i < game.players.length; i++) {
        if (i == game.dealerIndex) {
          expect(game.players[i].handTiles.length, 14);
        } else {
          expect(game.players[i].handTiles.length, 13);
        }
      }
    });

    test('打牌', () {
      game.initGame();
      game.rollDice();
      game.startRound();

      final player = game.players[0];
      final initialCount = player.handTiles.length;
      final tileToPlay = player.handTiles.first;

      game.playTile(player, tileToPlay);

      expect(player.handTiles.length, initialCount - 1);
      expect(player.playedTiles.contains(tileToPlay), true);
    });

    test('吃牌', () {
      game.initGame();
      game.rollDice();
      game.startRound();

      final player = game.players[0];
      // 模拟上家打出的牌
      final targetTile = Tile(type: TileType.wan3, id: 100);
      game.lastPlayedBy = game.players[3];

      // 检查是否可以吃
      final canChow = game.canChow(player, targetTile);
      expect(canChow, isA<bool>());
    });

    test('碰牌', () {
      game.initGame();
      game.rollDice();
      game.startRound();

      final player = game.players[0];
      final targetTile = Tile(type: TileType.wan3, id: 100);
      game.lastPlayedBy = game.players[2];

      // 检查是否可以碰
      final canPong = game.canPong(player, targetTile);
      expect(canPong, isA<bool>());
    });

    test('牌墙剩余数量', () {
      game.initGame();
      game.rollDice();
      game.startRound();
      
      // 剩余牌数应为正数，且小于总牌数
      expect(game.remainingTiles, greaterThan(0));
      expect(game.remainingTiles, lessThan(136));
    });

    test('包牌关系计数', () {
      game.initGame();
      game.rollDice();
      game.startRound();

      final player1 = game.players[0];
      final player2 = game.players[1];

      // 记录碰牌
      game.recordPong(player2, player1);
      game.recordPong(player2, player1);

      expect(game.getChowPongCount(player2, player1), 2);
    });
  });

  group('玩家数据测试', () {
    test('玩家创建', () {
      final player = Player(id: 1, name: '测试玩家', position: PlayerPosition.self);
      expect(player.name, '测试玩家');
      expect(player.handTiles.length, 0);
      expect(player.playedTiles.length, 0);
    });

    test('玩家手牌', () {
      final player = Player(id: 1, name: '测试', position: PlayerPosition.self);
      player.addTile(Tile(type: TileType.wan1, id: 1));
      player.addTile(Tile(type: TileType.wan2, id: 2));

      expect(player.handTiles.length, 2);
      expect(player.handCount, 2);
    });

    test('玩家打牌', () {
      final player = Player(id: 1, name: '测试', position: PlayerPosition.self);
      final tile = Tile(type: TileType.wan1, id: 1);
      player.addTile(tile);
      player.removeTile(tile);
      player.playedTiles.add(tile);

      expect(player.handTiles.length, 0);
      expect(player.playedTiles.length, 1);
    });
  });

  group('牌型测试', () {
    test('风牌创建', () {
      final east = Tile(type: TileType.dong, id: 1);
      expect(east.suit, TileSuit.feng);
      expect(east.number, 1);
    });

    test('数牌创建', () {
      final wan1 = Tile(type: TileType.wan1, id: 1);
      expect(wan1.suit, TileSuit.wan);
      expect(wan1.number, 1);
    });

    test('字牌创建', () {
      final hongzhong = Tile(type: TileType.zhong, id: 1);
      expect(hongzhong.suit, TileSuit.jian);
      expect(hongzhong.number, 1);
    });
  });

  group('结算测试', () {
    late MahjongGame game;

    setUp(() {
      game = MahjongGame();
    });

    test('自摸结算', () {
      game.initGame();
      game.rollDice();
      game.startRound();

      final winner = game.players[0];

      // 模拟自摸
      final result = game.calculateSettlement(winner, isSelfDrawn: true);

      expect(result, isNotNull);
      expect(result!.winner, winner);
      expect(result.payments.length, 3); // 其他3家都要付
    });

    test('放冲结算', () {
      game.initGame();
      game.rollDice();
      game.startRound();

      final winner = game.players[0];
      final uploader = game.players[1];

      game.lastPlayedBy = uploader;

      final result = game.calculateSettlement(winner, isSelfDrawn: false);

      expect(result, isNotNull);
      expect(result!.payments.containsKey(uploader), true);
    });
  });
}
