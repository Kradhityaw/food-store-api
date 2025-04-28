using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SimpleStore.DTOs;
using SimpleStore.Models;

namespace SimpleStore.Controllers
{
    [Route("api/cart")]
    [ApiController]
    public class CartController(FoodStoreContext context) : ControllerBase
    {
        private FoodStoreContext _context = context;

        [HttpPost]
        public IActionResult AddToCart(CartDTO cart)
        {
            if (AppConfig.User == null)
            {
                return Unauthorized(new { Message = "Tidak terautentikasi!" });
            }

            Cart newCart = new Cart
            {
                UserId = AppConfig.User.UserId,
                ProductId = cart.ProductId,
                StoreId = cart.StoreId,
                Quantity = cart.Quantity,
            };

            _context.Carts.Add(newCart);
            _context.SaveChanges();

            return Ok(new { Message = "Berhasil menambahkan item ke keranjang!" });
        }

        [HttpGet]
        public IActionResult GetCart()
        {
            if (AppConfig.User == null)
            {
                return Unauthorized(new { Message = "Tidak terautentikasi!" });
            }

            var getUserCart = _context.Carts
                .Where(c => c.UserId == AppConfig.User.UserId)
                .GroupBy(c => c.StoreId)
                .Select(group => new 
                {
                    StoreID = group.Key,
                    StoreName = _context.Stores
                        .Where(s => s.StoreId == group.Key)
                        .Select(s => s.StoreName)
                        .FirstOrDefault(),
                    StoreAddress = _context.Stores
                        .Where(s => s.StoreId == group.Key)
                        .Select(s => s.Address)
                        .FirstOrDefault(),
                    Items = group.Select(cartItem => new 
                    {
                        CartID = cartItem.CartId,
                        ProductID = cartItem.ProductId,
                        ProductName = _context.Products
                            .Where(p => p.ProductId == cartItem.ProductId)
                            .Select(p => p.ProductName)
                            .FirstOrDefault(),
                        ProductImage = _context.Products
                            .Where(p => p.ProductId == cartItem.ProductId)
                            .Select(p => p.ImageUrl)
                            .FirstOrDefault(),
                        Quantity = cartItem.Quantity,
                        Price = _context.StoreProducts
                            .Where(sp => sp.StoreId == cartItem.StoreId && sp.ProductId == cartItem.ProductId)
                            .Select(sp => sp.Price)
                            .FirstOrDefault(),
                        Subtotal = cartItem.Quantity * _context.StoreProducts
                            .Where(sp => sp.StoreId == cartItem.StoreId && sp.ProductId == cartItem.ProductId)
                            .Select(sp => sp.Price)
                            .FirstOrDefault()
                    }).ToList(),
                    TotalItems = group.Sum(c => c.Quantity),
                    TotalAmount = group.Sum(cartItem => cartItem.Quantity * _context.StoreProducts
                        .Where(sp => sp.StoreId == cartItem.StoreId && sp.ProductId == cartItem.ProductId)
                        .Select(sp => sp.Price)
                        .FirstOrDefault())
                })
                .ToList();

            return Ok(getUserCart);
        }
    }
}
