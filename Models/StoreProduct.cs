using System;
using System.Collections.Generic;

namespace SimpleStore.Models;

public partial class StoreProduct
{
    public int StoreProductId { get; set; }

    public int? StoreId { get; set; }

    public int? ProductId { get; set; }

    public decimal Price { get; set; }

    public int StockQuantity { get; set; }

    public bool? IsAvailable { get; set; }

    public virtual Product? Product { get; set; }

    public virtual Store? Store { get; set; }
}
