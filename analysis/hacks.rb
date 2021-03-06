# Get max and min int values
class Integer
    N_BYTES = [42].pack('i').size
    N_BITS = N_BYTES * 8
    MAX = 2 ** (N_BITS - 2) - 1
    MIN = -MAX - 1
end

class String
    def is_i?
        !!(self =~ /^[-+]?[0-9]+$/)
    end
end
