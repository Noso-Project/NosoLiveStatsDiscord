import 'package:noso_live_stats_discord_bot/messages.dart';
import 'package:noso_live_stats_discord_bot/util.dart';

class Value<T> {
  final T _value;
  final TypeMessage _type;
  final String _lol = "🛠️";

  Value(this._value, this._type);

  String getValue() {
    String returnValue;

    if (_value is String) {
      returnValue = _value.isEmpty ? _lol : _value;
    } else if (_value is double || _value is int) {
      returnValue = _value == 0 ? _lol : _value.toString();
    } else {
      returnValue = _lol;
    }

    if (_type == TypeMessage.lastUpdate) {
      returnValue = "${Messages.latsUpdate} $returnValue";
    }
    if (_type == TypeMessage.price) {
      returnValue =
          "${Messages.currentPrice} $returnValue ${returnValue == _lol ? "" : "USDT"}";
    }
    if (_type == TypeMessage.activeNodes) {
      returnValue = "${Messages.activeNodes} $returnValue";
    }

    if (_type == TypeMessage.supply) {
      returnValue =
          "${Messages.supplyCoins} ${returnValue == _lol ? _lol : "${Util().formatNumber(int.parse(returnValue))}/21M"}";
    }

    if (_type == TypeMessage.locked) {
      returnValue =
          "${Messages.lockedCoins} ${returnValue == _lol ? _lol : Util().formatNumber(int.parse(returnValue))}";
    }

    if (_type == TypeMessage.marketcap) {
      returnValue =
          "${Messages.marketCap} ${Util().formatNumber(double.parse(returnValue))} ${returnValue == _lol ? "" : "USDT"}";
    }

    if (_type == TypeMessage.rewarDay) {
      returnValue = "${Messages.rewardDay} ${double.parse(returnValue).toStringAsFixed(2)}N";
    }

    print("$_type  $returnValue");
    return returnValue;
  }
}

enum TypeMessage {
  price,
  supply,
  lastUpdate,
  activeNodes,
  locked,
  marketcap,
  rewarDay
}
