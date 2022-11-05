# If it works, it works
# DATA
size = c('Large', 'Medium', 'Small')
location = c('Central Festival','Tesco Lotus','BigC')
menu <- data.frame(
  'face' = c('Hawaiian','Meat Deluxe', 'Pepperoni'),
  'price_large' = c(300, 350, 280),
  'price_medium' = c(240, 300, 220),
  'price_small' = c(200, 250, 200)
)
topping <- data.frame(
  'items' = c('Cheese','Pineapple', 'Meat', 'Pepperoni'),
  'price' = c(40,30,50,40)
)

sidedish <- data.frame(
  'items' = c('Spaghetti', 'French Fries', 'Chicken Wing'),
  'price' = c(70,60,80)
)

receipt <- list(
  'item' = c(),
  'price' = c()
)

# FUNCTIONS
# Save orders
note <- function(list){
  item <- list[[1]]
  price <- list[[2]]
  receipt$item <- c(receipt$item, item)
  receipt$price <- c(receipt$price, price)
  return(receipt)
}
# Choosing pizzas
pizza_order <- function(){
    print(menu)
    print('1: Hawaiian, 2: Meat Deluxe, 3: Pepperoni')
    pizza_id <- as.integer(readLines('stdin', n=1))
    print('Size (1 = large, 2=medium, 3= small)')
    size <- as.integer(readLines('stdin', n=1))
    item <- menu$face[pizza_id]
    price <- menu[pizza_id,size+1]
    return(list(item,price))
  }

# Choosing toppings
topping_order <- function(){
  print(topping)
  print('1:Cheese, 2:Pineaaple, 3:Meat, 4:Pepperoni')
  topping_id <- as.integer(readLines('stdin', n=1))
  item <- topping$items[topping_id]
  price <- topping[topping_id, 'price']
  return(list(item,price))
}

# Choosing sidedish
sidedish_order <- function(){
  print(sidedish)
  print('1:Spaghetti, 2:French Fries 3:Chicken Wing')
  sidedish_id <- as.integer(readLines('stdin', n=1))
  item <- sidedish[sidedish_id, 'items']
  price <- sidedish[sidedish_id, 'price']
  return(list(item,price))
}

# Free delivery?
reach_500 <- function(){
  if (sum(receipt$price) < 500){
    print(paste('You need to order more',500 - sum(receipt$price),'baht to get free delivery'))
    return(TRUE)
  } else {
    print('Your bill reached 500 baht, free delivery fees!')
    return(FALSE)
  }
}


# Operation start here
print("Welcome to Yare's Pizza Shop!!")
print("What bring you here?")
print("1:To order Pizzas, 2:Learning about data, 3:I want to be a generalist , 4:I need money")

action <- as.integer(readLines('stdin', n=1))
if (action == 1){
  need_pizza <- 'y'
  while (need_pizza != 'n' ){
    receipt <- note(pizza_order())
    print('Want to order more pizza? (Y/N)')
    need_pizza <- tolower(readLines('stdin', n=1))
  }
  # Choosing toppings
  print('Do you want to add topping? (Y/N)')
  need_topping <- tolower(readLines('stdin', n=1))
  while (need_topping != 'n'){
    receipt <- note(topping_order())
    print('More topping? (Y/N)')
    need_topping <- tolower(readLines('stdin', n=1))
  }
  # Choosing side dishes
  print('Any side dishes? (Y/N)')
  need_sidedish <- tolower(readLines('stdin', n=1))
  while (need_sidedish == 'y'){
    print('Any side dishes? (Y/N)')
    receipt <- note(sidedish_order())
    print('Want more side dishes? (Y/N)')
    need_sidedish <- tolower(readLines('stdin', n=1))
  }
  
  # Check if bill >= 500 baht
  while (reach_500()){
    print('Do you want to order more? (Y/N)')
    order_more <- tolower(readLines('stdin', n=1))
    while (order_more != 'n'){
      print('What do you want to order more?')
      print("1:Pizza, 2:Topping, 3:Sidedishes")
      order_again <- as.integer(readLines('stdin', n=1))
      if (order_again == 1){
        receipt <- note(pizza_order())
      } else if (order_again == 2){
        receipt <- note(topping_order())
      } else if (order_again == 3){
        receipt <- note(sidedish_order())
      }
      reach_500()
      print('You want to order more? (Y/N)')
      order_more <- tolower(readLines('stdin', n=1))
    }
    
    if (order_more == 'n'){
      break
    }
  }
  total_amount <- sum(receipt$price)
  # Choose to self-pickup or delivery
  print('1:Self-pickup, 2:Delivery services')
  delivery_or <- as.integer(readLines('stdin', n=1))
  # If delivery and bill less than 500, need to pay more 40 baht
  if(delivery_or == 2 & total_amount < 500){
    receipt$item <- c(receipt$item, 'Delivery Fees')
    receipt$price <- c(receipt$price, 40)
    total_amount <- sum(receipt$price)
    print('Since your bill is less than 500 baht, you have to pay additional fee 40 baht for deliver')
  } else if(delivery_or == 2 & total_amount >= 500){
    receipt$item <- c(receipt$item, 'Delivery Fees')
    receipt$price <- c(receipt$price, 0)
  } else{
    # Self-pickup choices
    print('1:Central Festival, 2:Tesco Lotus, 3:BigC')
    branch <- as.integer(readLines('stdin', n=1))
  }
  print('Here is your receipt!')
  print(data.frame(receipt))
  print(paste('Total amount:',total_amount))
  # Confirm your order or confirm your order JK
  print('Confirm your order? (Y/N)')
  confirm <- tolower(readLines('stdin', n=1))
  while (confirm == 'n' & confirm != 'y'){
    print('You want to cancel your order? (Y/N)' )
    cancel <- tolower(readLines('stdin', n=1))
    if (cancel == 'y') {
      print('Why Why Why???')
      break
    } else if (cancel == 'n') {
      print('Confirm your order? (Y/N)')
      confirm <- tolower(readLines('stdin', n=1))
    }
  }
  if (confirm == 'y' & delivery_or ==2){
    print("Please insert your name")
    name <- readLines('stdin', n=1)
    print("Please insert your phone numbers")
    readLines('stdin', n=1)
    print("Please insert your address")
    address <- readLines('stdin', n=1)
    print(paste('Thank you!',name , 'we will be there soon!'))
  } else if (confirm == 'y'){
    print("Please insert your name")
    name <- readLines('stdin', n=1)
    print("Please insert your phone numbers")
    phone_num <- readLines('stdin',1)
    print(paste('Thank you!',name,'we will make the food ready ASAP! See you at',location[branch]))
  } 
}else{
  print('Go to DataRockie facebook page')
}



