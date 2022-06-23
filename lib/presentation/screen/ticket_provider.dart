import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/ticket.dart';

class TicketNotifier extends StateNotifier<List<Ticket>> {
  TicketNotifier() : super([]);

  void setList(List<Ticket> tickets) {
    state = tickets;
  }

  void delete(Ticket ticket) {
    var newItems = [
      for (final aTicket in state)
        if (ticket.id != aTicket.id) aTicket,
    ];
    state = _updateSort(newItems);
  }

  void insert(Ticket ticket) {
    var newItems = [ticket, ...state];
    state = _updateSort(newItems);
  }

  void update(Ticket ticket) {
    List<Ticket> tickets = [];
    state.asMap().forEach((index, Ticket aTicket) {
      if (aTicket.id == ticket.id) {
        tickets.add(ticket.copyWith());
      } else {
        tickets.add(aTicket.copyWith());
      }
    });
    state = tickets;
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    var newItems = [...state];
    final Ticket item = newItems.removeAt(oldIndex);
    newItems.insert(newIndex, item);

    state = _updateSort(newItems);
  }

  List<Ticket> _updateSort(List<Ticket> _items) {
    List<Ticket> newItems = [];
    int lastIndex = _items.length - 1;
    _items.asMap().forEach((index, ticket) {
      int newSort = lastIndex - index;
      if (ticket.sort == newSort) {
        return;
      }
      newItems.add(ticket.copyWith(sort: newSort));
    });
    newItems.sort((a, b) {
      return a.sort - b.sort;
    });
    return [..._items];
  }
}

final ticketListProvider = StateNotifierProvider<TicketNotifier, List<Ticket>>(
    (ref) => TicketNotifier());
