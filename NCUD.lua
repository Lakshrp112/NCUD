math.randomseed(os.time())

-- Welcome message
local welcome_message = {
    "Welcome to the Numeric Cipher Up Down Tool!",
    "This program allows you to securely Cipher Up and Cipher Down numeric strings.",
    "To begin, please choose an option from the menu below."
}
print(welcome_message[1])
print(welcome_message[2])
print(string.rep("-", #welcome_message[2]))

-- Function to generate primes up to a given limit using the Sieve of Eratosthenes
function generate_primes(limit)
    local sieve = {}
    local primes = {}

    -- Initialize sieve: assume all numbers are prime
    for i = 2, limit do
        sieve[i] = true
    end

    -- Sieve of Eratosthenes
    for i = 2, math.sqrt(limit) do
        if sieve[i] then
            for j = i * i, limit, i do
                sieve[j] = false
            end
        end
    end

    -- Collect primes
    for i = 2, limit do
        if sieve[i] then
            primes[i] = true
        end
    end

    return primes
end

-- Generate primes from 2 to 9973 dynamically
local prime_numbers = generate_primes(9973)

function cipher_operation(input_string, key, mode)
    mode = mode or 'up'
    local position_shift = 0  -- To account for non-numeric characters
    local result_string = ""
    local cipher_key = ""

    if mode == 'up' then
        for i = 1, #input_string do
            local char = input_string:sub(i, i)
            if char:match("%d") then
                local digit = tonumber(char)
                local current_position = #result_string + position_shift + 1

                if prime_numbers[current_position] then
                    if digit == 0 then
                        result_string = result_string .. '0'
                        cipher_key = cipher_key .. '0'
                    else
                        local max_multiplier = math.floor(9 / digit)
                        local multiplier = max_multiplier > 0 and math.random(1, max_multiplier) or 1
                        result_string = result_string .. tostring(digit * multiplier)
                        cipher_key = cipher_key .. tostring(multiplier)
                    end
                elseif current_position % 2 == 0 then
                    local max_adder = 9 - digit
                    local adder = math.random(0, max_adder)
                    result_string = result_string .. tostring(digit + adder)
                    cipher_key = cipher_key .. tostring(adder)
                else
                    local max_subtractor = digit
                    local subtractor = math.random(0, max_subtractor)
                    result_string = result_string .. tostring(digit - subtractor)
                    cipher_key = cipher_key .. tostring(subtractor)
                end
            else
                result_string = result_string .. char
                cipher_key = cipher_key .. char
                position_shift = position_shift + 1
            end
        end
        return result_string, cipher_key

    elseif mode == 'down' and key then
        local index = 1
        for i = 1, #input_string do
            local char = input_string:sub(i, i)
            if char:match("%d") then
                local digit = tonumber(char)
                local cipher_key_digit = tonumber(key:sub(index, index))
                local current_position = #result_string + position_shift + 1

                if prime_numbers[current_position] then
                    if digit == 0 or cipher_key_digit == 0 then
                        result_string = result_string .. '0'
                    else
                        result_string = result_string .. tostring(math.floor(digit / cipher_key_digit))
                    end
                elseif current_position % 2 == 0 then
                    result_string = result_string .. tostring(digit - cipher_key_digit)
                else
                    result_string = result_string .. tostring(digit + cipher_key_digit)
                end
            else
                result_string = result_string .. char
                position_shift = position_shift + 1
            end
            index = index + 1
        end
        return result_string
    else
        error("Invalid mode.")
    end
end

-- Main loop
while true do
    print("\nSelect an option:")
    print("1. Cipher Up")
    print("2. Cipher Down")
    local option = io.read("*line"):gsub("%s+", "")

    if option ~= '1' and option ~= '2' then
        print("⚠️ Invalid choice. Please select either '1' to Cipher Up or '2' to Cipher Down.")
    else
        option = tonumber(option)

        if option == 1 then
            -- Cipher Up
            print("\n🔒 Enter the string you'd like to Cipher Up:")
            local input_down_string = io.read("*line"):gsub("%s+", "")
            
            -- Perform Cipher Up
            local ciphered_up_string, cipher_down_key = cipher_operation(input_down_string, nil, 'up')

            -- Test Cipher Down to verify
            local ciphered_down_test = cipher_operation(ciphered_up_string, cipher_down_key, 'down')

            if ciphered_down_test == input_down_string then
                print("\n✅ Cipher Up successful and verified!")
                print("🔑 Cipher Down Key (save this to cipher down): " .. cipher_down_key)
                print("🔐 Ciphered Up String: " .. ciphered_up_string)
            else
                print("❌ Error: The Cipher Up process failed the verification test. Please try again.")
            end
            break

        elseif option == 2 then
            -- Cipher Down
            print("\n🔓 Enter the string you'd like to Cipher Down:")
            local input_up_string = io.read("*line"):gsub("%s+", "")
            print("🔑 Enter the corresponding Cipher Down key:")
            local cipher_down_key = io.read("*line"):gsub("%s+", "")

            -- Perform Cipher Down
            local status, ciphered_down_string = pcall(cipher_operation, input_up_string, cipher_down_key, 'down')

            if status then
                print("\n✅ Cipher Down successful!")
                print("🔓 Ciphered Down String: " .. ciphered_down_string)
            else
                print("⚠️ Error: " .. ciphered_down_string)
            end
            break
        end
    end
end
