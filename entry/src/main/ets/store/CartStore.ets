/**
 * CartStore - 下单流程临时状态管理
 * 暂存选中乐器 + 租期参数，跨页面传递（详情→确认→支付）
 */
export class CartItem {
  instrumentId: number = 0;
  instrumentName: string = '';
  coverImage: string = '';
  monthlyPrice: number = 0;
  deposit: number = 0;
  selectedMonths: number = 6;

  constructor(id: number, name: string, image: string, price: number, deposit: number) {
    this.instrumentId = id;
    this.instrumentName = name;
    this.coverImage = image;
    this.monthlyPrice = price;
    this.deposit = deposit;
  }
}

export class CartStore {
  private static readonly KEY = 'cart_item';

  static setCartItem(item: CartItem): void {
    AppStorage.setOrCreate(CartStore.KEY, item);
  }

  static getCartItem(): CartItem | null {
    return AppStorage.get<CartItem>(CartStore.KEY);
  }

  static clearCart(): void {
    AppStorage.setOrCreate(CartStore.KEY, null);
  }
}
