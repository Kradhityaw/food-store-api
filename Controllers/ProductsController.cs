using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SimpleStore.Models;

namespace SimpleStore.Controllers
{
    [Route("api/products")]
    [ApiController]
    public class ProductsController(FoodStoreContext context) : ControllerBase
    {
        private FoodStoreContext _context = context;

        [HttpGet]
        public IActionResult All(string? search = "", int? categoryId = null)
        {
            var getProducts = _context.Products.AsQueryable();

            if (categoryId == null)
            {
                getProducts = _context.Products
                    .Where(f => f.ProductName.Contains(search));
            }
            else
            {
                getProducts = _context.Products
                    .Where(f => f.ProductName.Contains(search) && f.CategoryId == categoryId);
            }

            var getList = getProducts.Select(f => new
            {
                f.ProductId,
                f.ProductName,
                f.Description,
                f.Price,
                f.Category.CategoryName,
                f.StockQuantity,
                f.ImageUrl
            }).ToList();

            return Ok(getList);
        }

        [HttpGet("{productId}")]
        public IActionResult Detail(int productId)
        {
            var findProduct = _context.Products.Include(f => f.Category).FirstOrDefault(f => f.ProductId == productId);
            if (findProduct == null)
            {
                return NotFound(new { Message = "ID Produk tidak ditemukan!" });
            }
            
            return Ok(findProduct);
        }
    }
}
