int main(string[] args) {
    assert(args.length == 2);
    switch (int.parse(args[1])) {
      case 1:
        {
            SimpleList<int> list = new SimpleList<int>();
            list.add(1);
            list.add(2);
            list.add(3);
            assert(list.size == 3);
            assert(list[0] == 1);
            assert(list[1] == 2);
            assert(list[2] == 3);
        }
        break;
      case 2:
        {
            SimpleList<int> list = new SimpleList<int>.from_data(1, 2, 3);
            list.insert(0, 4);
            assert(list.size == 4);
            assert(list[0] == 4);
            assert(list[1] == 1);
            assert(list[2] == 2);
            assert(list[3] == 3);
        }
        break;
      case 3:
        {
            SimpleList<int> list = new SimpleList<int>.from_data(1, 2, 3);
            list.insert(1, 4);
            assert(list.size == 4);
            assert(list[0] == 1);
            assert(list[1] == 4);
            assert(list[2] == 2);
            assert(list[3] == 3);
        }
        break;
      case 4:
        {
            SimpleList<int> list = new SimpleList<int>.from_data(1, 2, 3);
            list.insert(2, 4);
            assert(list.size == 4);
            assert(list[0] == 1);
            assert(list[1] == 2);
            assert(list[2] == 4);
            assert(list[3] == 3);
        }
        break;
      case 5:
        {
            SimpleList<int> list = new SimpleList<int>.from_data(1, 2, 3);
            list.insert(3, 4);
            assert(list.size == 4);
            assert(list[0] == 1);
            assert(list[1] == 2);
            assert(list[2] == 3);
            assert(list[3] == 4);
        }
        break;
      case 6:
        {
            print("Expect assertion will fail\n");
            SimpleList<int> list = new SimpleList<int>.from_data(1, 2, 3);
            list.insert(4, 4);
            assert(list.size == 3);
            assert(list[0] == 1);
            assert(list[1] == 2);
            assert(list[2] == 3);
        }
        break;
      case 7:
        {
            SimpleList<int> list = new SimpleList<int>.from_data(1, 2, 3);
            list.add(4);
            assert(list.size == 4);
            assert(list[0] == 1);
            assert(list[1] == 2);
            assert(list[2] == 3);
            assert(list[3] == 4);
        }
        break;
      case 8:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3);
            SimpleList<int> list2 = new SimpleList<int>.from_data(4, 5, 6);
            list1.add_all(list2);
            assert(list1.size == 6);
            assert(list2.size == 0);
            assert(list1[0] == 1);
            assert(list1[1] == 2);
            assert(list1[2] == 3);
            assert(list1[3] == 4);
            assert(list1[4] == 5);
            assert(list1[5] == 6);
        }
        break;
      case 9:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3);
            SimpleList<int> list2 = new SimpleList<int>.from_data(4, 5, 6);
            list1.insert_all(0, list2);
            assert(list1.size == 6);
            assert(list2.size == 0);
            assert(list1[0] == 4);
            assert(list1[1] == 5);
            assert(list1[2] == 6);
            assert(list1[3] == 1);
            assert(list1[4] == 2);
            assert(list1[5] == 3);
        }
        break;
      case 10:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3);
            SimpleList<int> list2 = new SimpleList<int>.from_data(4, 5, 6);
            list1.insert_all(1, list2);
            assert(list1.size == 6);
            assert(list2.size == 0);
            assert(list1[0] == 1);
            assert(list1[1] == 4);
            assert(list1[2] == 5);
            assert(list1[3] == 6);
            assert(list1[4] == 2);
            assert(list1[5] == 3);
        }
        break;
      case 11:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3);
            SimpleList<int> list2 = new SimpleList<int>.from_data(4, 5, 6);
            list1.insert_all(2, list2);
            assert(list1.size == 6);
            assert(list2.size == 0);
            assert(list1[0] == 1);
            assert(list1[1] == 2);
            assert(list1[2] == 4);
            assert(list1[3] == 5);
            assert(list1[4] == 6);
            assert(list1[5] == 3);
        }
        break;
      case 12:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3);
            SimpleList<int> list2 = new SimpleList<int>.from_data(4, 5, 6);
            list1.insert_all(3, list2);
            assert(list1.size == 6);
            assert(list2.size == 0);
            assert(list1[0] == 1);
            assert(list1[1] == 2);
            assert(list1[2] == 3);
            assert(list1[3] == 4);
            assert(list1[4] == 5);
            assert(list1[5] == 6);
        }
        break;
      case 13:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            SimpleList<int> list2 = list1.cut_at(0);
            assert(list1.size == 6);
            assert(list2.size == 0);
            assert(list1[0] == 1);
            assert(list1[1] == 2);
            assert(list1[2] == 3);
            assert(list1[3] == 4);
            assert(list1[4] == 5);
            assert(list1[5] == 6);
        }
        break;
      case 14:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            SimpleList<int> list2 = list1.cut_at(1);
            assert(list1.size == 1);
            assert(list2.size == 5);
            assert(list1[0] == 1);
            assert(list2[0] == 2);
            assert(list2[1] == 3);
            assert(list2[2] == 4);
            assert(list2[3] == 5);
            assert(list2[4] == 6);
        }
        break;
      case 15:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            SimpleList<int> list2 = list1.cut_at(2);
            assert(list1.size == 2);
            assert(list2.size == 4);
            assert(list1[0] == 1);
            assert(list1[1] == 2);
            assert(list2[0] == 3);
            assert(list2[1] == 4);
            assert(list2[2] == 5);
            assert(list2[3] == 6);
        }
        break;
      case 16:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            SimpleList<int> list2 = list1.cut_at(3);
            assert(list1.size == 3);
            assert(list2.size == 3);
            assert(list1[0] == 1);
            assert(list1[1] == 2);
            assert(list1[2] == 3);
            assert(list2[0] == 4);
            assert(list2[1] == 5);
            assert(list2[2] == 6);
        }
        break;
      case 17:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            SimpleList<int> list2 = list1.cut_at(4);
            assert(list1.size == 4);
            assert(list2.size == 2);
            assert(list1[0] == 1);
            assert(list1[1] == 2);
            assert(list1[2] == 3);
            assert(list1[3] == 4);
            assert(list2[0] == 5);
            assert(list2[1] == 6);
        }
        break;
      case 18:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            SimpleList<int> list2 = list1.cut_at(5);
            assert(list1.size == 5);
            assert(list2.size == 1);
            assert(list1[0] == 1);
            assert(list1[1] == 2);
            assert(list1[2] == 3);
            assert(list1[3] == 4);
            assert(list1[4] == 5);
            assert(list2[0] == 6);
        }
        break;
      case 19:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            SimpleList<int> list2 = list1.cut_at(6);
            assert(list1.size == 6);
            assert(list2.size == 0);
            assert(list1[0] == 1);
            assert(list1[1] == 2);
            assert(list1[2] == 3);
            assert(list1[3] == 4);
            assert(list1[4] == 5);
            assert(list1[5] == 6);
        }
        break;
      case 20:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            SimpleList<int> list2 = list1.remove(0, 4);
            assert(list1.size == 2);
            assert(list2.size == 4);
            assert(list1[0] == 5);
            assert(list1[1] == 6);
            assert(list2[0] == 1);
            assert(list2[1] == 2);
            assert(list2[2] == 3);
            assert(list2[3] == 4);
        }
        break;
      case 21:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            SimpleList<int> list2 = list1.remove(1, 4);
            assert(list1.size == 2);
            assert(list2.size == 4);
            assert(list1[0] == 1);
            assert(list1[1] == 6);
            assert(list2[0] == 2);
            assert(list2[1] == 3);
            assert(list2[2] == 4);
            assert(list2[3] == 5);
        }
        break;
      case 22:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            SimpleList<int> list2 = list1.remove(2, 4);
            assert(list1.size == 2);
            assert(list2.size == 4);
            assert(list1[0] == 1);
            assert(list1[1] == 2);
            assert(list2[0] == 3);
            assert(list2[1] == 4);
            assert(list2[2] == 5);
            assert(list2[3] == 6);
        }
        break;
      case 23:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            SimpleList<int> list2 = list1.slice_cut(0, 4);
            assert(list1.size == 2);
            assert(list2.size == 4);
            assert(list1[0] == 5);
            assert(list1[1] == 6);
            assert(list2[0] == 1);
            assert(list2[1] == 2);
            assert(list2[2] == 3);
            assert(list2[3] == 4);
        }
        break;
      case 24:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            SimpleList<int> list2 = list1.slice_cut(1, 5);
            assert(list1.size == 2);
            assert(list2.size == 4);
            assert(list1[0] == 1);
            assert(list1[1] == 6);
            assert(list2[0] == 2);
            assert(list2[1] == 3);
            assert(list2[2] == 4);
            assert(list2[3] == 5);
        }
        break;
      case 25:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            SimpleList<int> list2 = list1.slice_cut(2, 6);
            assert(list1.size == 2);
            assert(list2.size == 4);
            assert(list1[0] == 1);
            assert(list1[1] == 2);
            assert(list2[0] == 3);
            assert(list2[1] == 4);
            assert(list2[2] == 5);
            assert(list2[3] == 6);
        }
        break;
      case 26:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            int a = list1.remove_at(0);
            assert(list1.size == 5);
            assert(a == 1);
            assert(list1[0] == 2);
            assert(list1[1] == 3);
            assert(list1[2] == 4);
            assert(list1[3] == 5);
            assert(list1[4] == 6);
        }
        break;
      case 27:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            int a = list1.remove_at(1);
            assert(list1.size == 5);
            assert(a == 2);
            assert(list1[0] == 1);
            assert(list1[1] == 3);
            assert(list1[2] == 4);
            assert(list1[3] == 5);
            assert(list1[4] == 6);
        }
        break;
      case 28:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            int a = list1.remove_at(2);
            assert(list1.size == 5);
            assert(a == 3);
            assert(list1[0] == 1);
            assert(list1[1] == 2);
            assert(list1[2] == 4);
            assert(list1[3] == 5);
            assert(list1[4] == 6);
        }
        break;
      case 29:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            int a = list1.remove_at(3);
            assert(list1.size == 5);
            assert(a == 4);
            assert(list1[0] == 1);
            assert(list1[1] == 2);
            assert(list1[2] == 3);
            assert(list1[3] == 5);
            assert(list1[4] == 6);
        }
        break;
      case 30:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            int a = list1.remove_at(4);
            assert(list1.size == 5);
            assert(a == 5);
            assert(list1[0] == 1);
            assert(list1[1] == 2);
            assert(list1[2] == 3);
            assert(list1[3] == 4);
            assert(list1[4] == 6);
        }
        break;
      case 31:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            int a = list1.remove_at(5);
            assert(list1.size == 5);
            assert(a == 6);
            assert(list1[0] == 1);
            assert(list1[1] == 2);
            assert(list1[2] == 3);
            assert(list1[3] == 4);
            assert(list1[4] == 5);
        }
        break;
      case 32:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1, 2, 3, 4, 5, 6);
            int a = list1.remove_at(6);
        }
        break;
      case 33:
        {
            SimpleList<int> list1 = new SimpleList<int>.from_data(1);
            int a = list1.remove_at(0);
            assert(a == 1);
            assert(list1.size == 0);
        }
        break;
      default:
        return 1;
    }
    return 0;
}
