import 'dart:convert';
import 'dart:io';
import 'package:mahjong_v2/game_logic/mahjong_game.dart';

void main() {
  final sim = MaxWinSimulator(games: 200, maxSteps: 8000);
  final best = sim.run();
  if (best == null) {
    print('No wins found.');
    return;
  }
  final out = File('ai_logs/max_win_simulation_real.json');
  out.createSync(recursive: true);
  out.writeAsStringSync(_pretty(best));
  print('Saved: ${out.path}');
  print(_pretty(best));
}

class MaxWinSimulator {
  final int games;
  final int maxSteps;

  MaxWinSimulator({required this.games, required this.maxSteps});

  Map<String, dynamic>? run() {
    Map<String, dynamic>? best;
    int bestDelta = -999999;
    for (int g = 1; g <= games; g++) {
      final res = _runOne(g);
      if (res == null) continue;
      final win = res['max_win'] as Map<String, dynamic>;
      final delta = win['winner_delta'] as int;
      if (delta > bestDelta) {
        bestDelta = delta;
        best = res;
      }
    }
    return best;
  }

  Map<String, dynamic>? _runOne(int gameIndex) {
    final game = MahjongGame();
    game.simulationMode = true;
    game.useMonteCarloAI = true;
    game.monteCarloBudget = const Duration(milliseconds: 2);
    game.monteCarloTrials = 30;
    game.aiRespondDelay = Duration.zero;
    game.aiDiscardDelay = Duration.zero;
    game.responseWindowDuration = Duration.zero;

    game.rollDice();
    game.deal();

    final dealerIndex = game.dealerIndex;
    bool dealerFirst = true;
    int steps = 0;

    final winRecords = <Map<String, dynamic>>[];

    while (!game.gameEnded && steps < maxSteps) {
      steps++;

      // 有弃牌等待响应
      if (game.pendingTile != null) {
        final huPlayers = _collectHuPlayers(game);
        if (huPlayers.isNotEmpty) {
          final shooter = game.currentPlayerIndex;
          for (final w in huPlayers) {
            final rec = _buildWinRecord(game, w, isSelfDraw: false, fromIndex: shooter);
            winRecords.add(rec);
            game.claimHu(w);
          }
          game.resolveMultiHuFromPlayer();
          continue;
        }

        final responder = _findResponder(game);
        if (responder != null) {
          if (responder == 0) {
            _manualRespond(game, responder);
          } else {
            game.aiPlay(responder);
          }
          continue;
        }

        // 无人响应 → 下家摸牌
        game.pendingTile = null;
        game.currentPlayerIndex = _nextActive(game, game.currentPlayerIndex);
      }

      // 轮到当前玩家
      final idx = game.currentPlayerIndex;
      if (game.eliminatedPlayers.contains(idx)) {
        game.currentPlayerIndex = _nextActive(game, idx);
        continue;
      }
      final p = game.players[idx];

      // 庄家首轮不摸牌，直接打
      if (!(dealerFirst && idx == dealerIndex)) {
        game.drawTile(p);
      }
      dealerFirst = false;

      if (game.canHu(p)) {
        final rec = _buildWinRecord(game, idx, isSelfDraw: true);
        winRecords.add(rec);
        game.playerWins(idx);
        continue;
      }

      // 打牌
      game.aiDiscard(idx);
    }

    if (winRecords.isEmpty) return null;

    winRecords.sort((a, b) => (b['winner_delta'] as int).compareTo(a['winner_delta'] as int));
    return {
      'game_index': gameIndex,
      'steps': steps,
      'max_win': winRecords.first,
      'all_wins': winRecords,
    };
  }

  Map<String, dynamic> _buildWinRecord(MahjongGame game, int winnerIndex,
      {required bool isSelfDraw, int? fromIndex}) {
    if (isSelfDraw) {
      game.lastWinFromDiscard = false;
      game.lastPlayedTile = null;
      game.lastDiscarderIndex = null;
    } else {
      game.lastWinFromDiscard = true;
      game.lastPlayedTile = game.pendingTile;
      game.lastDiscarderIndex = fromIndex;
    }

    final summary = game.buildWinSummary(winnerIndex, isSelfDraw: isSelfDraw);
    final settlement = game.previewSettlement(winnerIndex);
    final delta = settlement.deltas[winnerIndex] ?? 0;

    return {
      'winner_index': winnerIndex,
      'winner_name': game.players[winnerIndex].name,
      'win_type': isSelfDraw ? '自摸' : '点炮',
      'from_index': fromIndex,
      'from_name': fromIndex != null ? game.players[fromIndex].name : null,
      'hu_type': summary['hu_type'],
      'reason': summary['reason'],
      'base_points': summary['base_points'],
      'round_multiplier': summary['round_multiplier'],
      'extra_multiplier': summary['extra_multiplier'],
      'total_points': summary['total_points'],
      'melds': summary['melds'],
      'meld_sources': summary['meld_sources'],
      'details': settlement.details,
      'deltas': settlement.deltas,
      'winner_delta': delta,
    };
  }

  int _nextActive(MahjongGame game, int from) {
    int idx = from;
    for (int i = 0; i < 4; i++) {
      idx = (idx + 3) % 4;
      if (!game.eliminatedPlayers.contains(idx)) return idx;
    }
    return from;
  }

  List<int> _collectHuPlayers(MahjongGame game) {
    final res = <int>[];
    for (int offset = 1; offset <= 3; offset++) {
      final idx = (game.currentPlayerIndex + offset) % 4;
      if (game.eliminatedPlayers.contains(idx)) continue;
      if (game.canHu(game.players[idx])) res.add(idx);
    }
    return res;
  }

  int? _findResponder(MahjongGame game) {
    if (game.pendingTile == null) return null;
    for (int offset = 1; offset <= 3; offset++) {
      final idx = (game.currentPlayerIndex + offset) % 4;
      if (game.eliminatedPlayers.contains(idx)) continue;
      final p = game.players[idx];
      if (game.getKongableTiles(p).isNotEmpty) return idx;
      if (game.canPong(p)) return idx;
      if (idx == (game.currentPlayerIndex + 1) % 4 && game.canChow(p)) return idx;
    }
    return null;
  }

  void _manualRespond(MahjongGame game, int playerIndex) {
    final p = game.players[playerIndex];
    final tiles = game.getKongableTiles(p);
    if (tiles.isNotEmpty) {
      game.doKong(p, tiles.first, isHidden: game.pendingTile == null);
      game.drawTile(p, isKongDraw: true);
      game.aiDiscard(playerIndex);
      return;
    }
    if (game.canPong(p)) {
      game.doPong(p);
      game.drawTile(p);
      game.aiDiscard(playerIndex);
      return;
    }
    if (playerIndex == (game.currentPlayerIndex + 1) % 4 && game.canChow(p)) {
      game.doChow(p, null);
      game.drawTile(p);
      game.aiDiscard(playerIndex);
    }
  }
}

String _pretty(Map<String, dynamic> best) {
  final buf = StringBuffer();
  final maxWin = best['max_win'] as Map<String, dynamic>;
  buf.writeln('Max win game: #${best['game_index']} steps=${best['steps']}');
  buf.writeln('Winner: ${maxWin['winner_name']}(${maxWin['winner_index']}) delta=${maxWin['winner_delta']}');
  buf.writeln('Win type: ${maxWin['win_type']}  From: ${maxWin['from_name'] ?? '-'}');
  buf.writeln('Hu type: ${maxWin['hu_type']}  Reason: ${maxWin['reason']}');
  buf.writeln('Base: ${maxWin['base_points']}  Round×${maxWin['round_multiplier']}  Extra×${maxWin['extra_multiplier']}  Total=${maxWin['total_points']}');
  buf.writeln('Deltas: ${maxWin['deltas']}');
  final details = (maxWin['details'] as List?) ?? [];
  if (details.isNotEmpty) {
    buf.writeln('Details: ${details.join(' | ')}');
  }
  final allWins = best['all_wins'] as List;
  buf.writeln('All wins in game: ${allWins.length}');
  for (final w in allWins) {
    buf.writeln(' - ${w['winner_name']}(${w['winner_index']}) ${w['win_type']} ${w['hu_type']} total=${w['total_points']} delta=${w['winner_delta']}');
  }
  return buf.toString();
}
